pipeline {
    agent any
    stages {
        stage('Connect to MongoDB') {
            steps {
                script {
                    def mongo = new MongoClient("mongodb://<username>:<password>@<host>:<port>/<dbname>")
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
