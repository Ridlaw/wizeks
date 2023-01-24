pipeline {
    agent any
    stages {
        stage('Connect to MongoDB') {
            steps {
                script {
                    def mongo = new MongoClient("bW9uZ29kYjovL3JpZHdpelVzZXI6MTIzTW9uZ29AMy44MS42NS4xOTI6MjcwMTcvdGVzdA==")
                }
            }
        }
        stage('Run a Query') {
            steps {
                script {
                    def db = mongo.getDB("<dbname>")
                    def coll = db.getCollection("<collection>")
                    def result = coll.find()
                    while (result.hasNext()) {
                        println result.next()
                    }
                }
            }
        }
    }
}
