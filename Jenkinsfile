pipeline {                                                // Mendefinisikan blok pipeline untuk CI/CD Jenkins
    agent any                                             // Menjalankan pipeline pada agen Jenkins yang tersedia
    
    tools {                                              // Mendefinisikan tools yang dibutuhkan untuk pipeline
        nodejs 'NodeJS 18'                               // Menggunakan Node.js versi 18 untuk aplikasi frontend Vue.js
    }
    
    parameters {                                         // Mendefinisikan parameter yang dapat diatur saat menjalankan pipeline
        string(name: 'RELEASE_TAG',                      // Parameter string untuk tag rilis
               defaultValue: '', 
               description: 'Release tag to build and deploy (kosongkan untuk menggunakan build number)')
        choice(name: 'DEPLOY_ENV',                       // Parameter pilihan untuk environment deployment
               choices: ['development', 'production'], 
               description: 'Environment to deploy')
    }
    
    environment {                                        // Mendefinisikan variabel lingkungan untuk pipeline
        DOCKER_HUB_CREDS = credentials('docker-hub')     // Mengambil kredensial Docker Hub dari Jenkins credentials
        DOCKER_HUB_PAT = credentials('docker-hub-pat')   // Mengambil Personal Access Token Docker Hub
        DISCORD_WEBHOOK = credentials('discord-notification') // Mengambil webhook Discord untuk notifikasi
        APP_NAME = 'karsajobs-ui'                       // Nama aplikasi frontend untuk container Docker
        DOCKER_IMAGE = "ardidafa/${APP_NAME}"           // Nama image Docker yang akan dibuat
        IMAGE_TAG = "${params.RELEASE_TAG ? params.RELEASE_TAG : env.BUILD_NUMBER}" // Tag image: gunakan RELEASE_TAG jika ada, jika tidak gunakan nomor build
    
    stages {                                           // Mendefinisikan tahapan-tahapan dalam pipeline
        stage('Checkout') {                             // Tahap mengambil kode dari repositori
            steps {                                     // Langkah-langkah yang dijalankan dalam tahap ini
                checkout scm                            // Mengambil kode dari Source Control Management (Git)
                script {                                // Blok script untuk menjalankan kode Groovy
                    try {                               // Mencoba mengirim notifikasi Discord
                        discordSend(
                            webhookURL: DISCORD_WEBHOOK, // URL webhook Discord untuk notifikasi
                            title: "BUILD STARTED: ${env.JOB_NAME} #${env.BUILD_NUMBER}", // Judul notifikasi
                            description: "Build started for ${env.JOB_NAME} #${env.BUILD_NUMBER}", // Deskripsi notifikasi
                            link: env.BUILD_URL,        // Link ke halaman build Jenkins
                            result: 'STARTED'           // Status build: dimulai
                        )
                    } catch (Exception e) {              // Menangkap error jika notifikasi gagal
                        echo "Discord notification failed: ${e.message}" // Menampilkan pesan error
                    }
                }
            }
        }
        
        stage('Lint Dockerfile') {                      // Tahap memeriksa kualitas Dockerfile
            // Menjalankan perintah shell multi-baris
            steps {
                sh '''                                  
                # Use docker to run hadolint instead of downloading it
                docker run --rm -i hadolint/hadolint < Dockerfile || true 
                '''                                     // || true: lanjutkan pipeline meskipun ada warning
                // Menjalankan hadolint dalam container Docker
            }
        }
        
        stage('Docker Build') {                         // Tahap membangun image Docker untuk frontend
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} -t ${DOCKER_IMAGE}:latest ." // Membuat image dengan tag versi dan latest
            }
        }
        
        stage('Docker Push') {                          // Tahap mengunggah image ke Docker Hub
            steps {
                sh "echo ${DOCKER_HUB_PAT} | docker login -u ardidafa --password-stdin" // Login ke Docker Hub menggunakan PAT
                sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}" // Mengunggah image dengan tag versi
                sh "docker push ${DOCKER_IMAGE}:latest"      // Mengunggah image dengan tag latest
            }
        }
    }
    
    post {                                              // Mendefinisikan tindakan setelah pipeline selesai
        success {                                       // Tindakan jika pipeline berhasil
            script {                                    // Blok script untuk menjalankan kode Groovy
                try {                                   // Mencoba mengirim notifikasi Discord
                    discordSend(
                        webhookURL: DISCORD_WEBHOOK,     // URL webhook Discord untuk notifikasi
                        title: "BUILD SUCCESSFUL: ${env.JOB_NAME} #${env.BUILD_NUMBER}", // Judul notifikasi sukses
                        description: "Build completed successfully for ${env.JOB_NAME} #${env.BUILD_NUMBER}", // Deskripsi notifikasi
                        link: env.BUILD_URL,            // Link ke halaman build Jenkins
                        result: 'SUCCESS'               // Status build: sukses
                    )
                } catch (Exception e) {                  // Menangkap error jika notifikasi gagal
                    echo "Discord notification failed: ${e.message}" // Menampilkan pesan error
                }
            }
        }
        failure {                                       // Tindakan jika pipeline gagal
            script {                                    // Blok script untuk menjalankan kode Groovy
                try {                                   // Mencoba mengirim notifikasi Discord
                    discordSend(
                        webhookURL: DISCORD_WEBHOOK,     // URL webhook Discord untuk notifikasi
                        title: "BUILD FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}", // Judul notifikasi gagal
                        description: "Build failed for ${env.JOB_NAME} #${env.BUILD_NUMBER}", // Deskripsi notifikasi
                        link: env.BUILD_URL,            // Link ke halaman build Jenkins
                        result: 'FAILURE'               // Status build: gagal
                    )
                } catch (Exception e) {                  // Menangkap error jika notifikasi gagal
                    echo "Discord notification failed: ${e.message}" // Menampilkan pesan error
                }
            }
        }
        always {                                        // Tindakan yang selalu dijalankan, baik sukses maupun gagal
            // Clean up Docker images and builder cache
            withEnv([                                   // Menetapkan variabel lingkungan untuk blok shell
                "DOCKER_IMG=${DOCKER_IMAGE}",          // Variabel untuk nama image Docker
                "IMG_TAG=${IMAGE_TAG}"                 // Variabel untuk tag image
            ]) {
                // Menjalankan perintah shell multi-baris
                sh '''                                  
                    # Hapus image yang tidak terpakai
                    docker rmi $DOCKER_IMG:$IMG_TAG || true
                    docker rmi $DOCKER_IMG:latest || true
                    
                    # Bersihkan builder cache untuk mencegah penumpukan storage
                    docker builder prune -f || true             
                '''                                     // || true: lanjutkan meskipun ada error
                // Menghapus image dengan tag versi dan latest
                // Membersihkan cache builder Docker
            }
            cleanWs()                                  // Membersihkan workspace Jenkins setelah build selesai
        }
    }
}