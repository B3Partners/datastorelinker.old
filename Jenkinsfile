timestamps {

    properties([
        [$class: 'jenkins.model.BuildDiscarderProperty', strategy: [$class: 'LogRotator',
            artifactDaysToKeepStr: '8',
            artifactNumToKeepStr: '3',
            daysToKeepStr: '15',
            numToKeepStr: '5']
        ]]);

    node {
        withEnv(["JAVA_HOME=${ tool 'JDK8' }", "PATH+MAVEN=${tool 'Maven 3.6.0'}/bin:${env.JAVA_HOME}/bin"]) {

            stage('Prepare') {
                checkout scm
            }

            stage('Build') {
                echo "Building branch: ${env.BRANCH_NAME}"
                sh "mvn install -B -V -e -fae -q"
            }

            stage('Test') {
                echo "Running unit tests"
                sh "mvn -e test -B"
            }

            stage('Publish Test Results') {
                junit allowEmptyResults: true, testResults: '**/target/surefire-reports/TEST-*.xml, **/target/failsafe-reports/TEST-*.xml'
            }

            stage('OWASP Dependency Check') {
                echo "Uitvoeren OWASP dependency check"
                sh "mvn org.owasp:dependency-check-maven:check -Dformat=ALL -DsuppressionFile=./.mvn/owasp-suppression.xml"

                dependencyCheckPublisher canComputeNew: false, defaultEncoding: '', healthy: '85', pattern: '**/dependency-check-report.xml', shouldDetectModules: true, unHealthy: ''
            }

        }
    }
}
