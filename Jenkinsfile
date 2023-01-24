pipeline {
    agent any
    stages {
        stage('Connect to MongoDB') {
            steps {
                script {
                    def mongo = new MongoClient("mongodb://ridwizUser:123Mongo@18.212.132.144:27017/test")
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
