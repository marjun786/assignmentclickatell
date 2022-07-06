# Solution to the assignment problem

*******************************************************************************************

## **Phase 1: Creating basic infrastructure**

1. Created Amazon EKS cluster for deployment testing and automation

2. Create nodegroup with 2 nodes

3. Updated local kubectl with the cluster kubeconfig using the command

  aws eks --region us-east-2 update-kubeconfig --name eksassigncluster

4. Connected to the cluster and verified

```
kubectl get nodes
NAME                                         STATUS   ROLES    AGE   VERSION
ip-172-31-44-62.us-east-2.compute.internal   Ready    <none>   59m   v1.21.2-eks-c1718fb
ip-172-31-8-215.us-east-2.compute.internal   Ready    <none>   59m   v1.21.2-eks-c1718fb

```

5. Installed all basic softwares on my centralized EC2 instance like git, docker, kubectl and also configured AWS CLI using credentials.

************************************************************************************************


## **Phase 2: Testing the springboot on local machine**

1. Go to springboot application  

2. Check src/main/java/example/HomeController.java 

3. Modidy the message 

4. Run ./gradlew bootRun 

```
[root@ip-172-31-2-193 initial]# ./gradlew bootRun

> Task :bootRun

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v2.7.1)

2022-07-06 16:22:46.825  INFO 15015 --- [           main] com.example.springboot                                                                                        .Application       : Starting Application using Java 17.0.3 on ip-172-31-2-193.c                                                                                        a-central-1.compute.internal with PID 15015 (/root/gs-spring-boot/initial/build/                                                                                        classes/java/main started by root in /root/gs-spring-boot/initial)
2022-07-06 16:22:46.829  INFO 15015 --- [           main] com.example.springboot                                                                                        .Application       : No active profile set, falling back to 1 default profile: "                                                                                        default"
2022-07-06 16:22:47.819  INFO 15015 --- [           main] o.s.b.w.embedded.tomca                                                                                        t.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
2022-07-06 16:22:47.830  INFO 15015 --- [           main] o.apache.catalina.core                                                                                        .StandardService   : Starting service [Tomcat]
2022-07-06 16:22:47.830  INFO 15015 --- [           main] org.apache.catalina.co                                                                                        re.StandardEngine  : Starting Servlet engine: [Apache Tomcat/9.0.64]
2022-07-06 16:22:47.917  INFO 15015 --- [           main] o.a.c.c.C.[Tomcat].[lo                                                                                        calhost].[/]       : Initializing Spring embedded WebApplicationContext
2022-07-06 16:22:47.917  INFO 15015 --- [           main] w.s.c.ServletWebServer                                                                                        ApplicationContext : Root WebApplicationContext: initialization completed in 102                                                                                        2 ms
2022-07-06 16:22:48.200  INFO 15015 --- [           main] o.s.b.w.embedded.tomca                                                                                        t.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path '
2022-07-06 16:22:48.209  INFO 15015 --- [           main] com.example.springboot                                                                                        .Application       : Started Application in 1.731 seconds (JVM running for 2.135                                                                                        )
Let's inspect the beans provided by Spring Boot:
application
applicationAvailability
applicationTaskExecutor
basicErrorController
beanNameHandlerMapping
beanNameViewResolver
characterEncodingFilter
conventionErrorViewResolver
defaultServletHandlerMapping
defaultViewResolver
dispatcherServlet
dispatcherServletRegistration
error
errorAttributes
errorPageCustomizer
errorPageRegistrarBeanPostProcessor
flashMapManager
forceAutoProxyCreatorToUseClassProxying
formContentFilter
handlerExceptionResolver
handlerFunctionAdapter
helloController
httpRequestHandlerAdapter
jacksonObjectMapper
jacksonObjectMapperBuilder
jsonComponentModule
jsonMixinModule
lifecycleProcessor
localeCharsetMappingsCustomizer
localeResolver
mappingJackson2HttpMessageConverter
messageConverters
multipartConfigElement
multipartResolver
mvcContentNegotiationManager
mvcConversionService
mvcHandlerMappingIntrospector
mvcPathMatcher
mvcPatternParser
mvcResourceUrlProvider
mvcUriComponentsContributor
mvcUrlPathHelper
mvcValidator
``` 

************************************************************************************************

## **Phase 3: Creating the custom image for Http Server**

1. Created the Dockerfile code for containerizing 

```
FROM alpine:latest
COPY springboot /springboot
RUN apk update
RUN apk add openjdk11
RUN apk add curl
RUN apk add --no-cache bash
RUN apk add --upgrade zip
RUN chmod +x /root/.sdkman/bin/sdkman-init.sh
RUN \
    cd /usr/local && \
    curl -L https://services.gradle.org/distributions/gradle-2.5-bin.zip -o gradle-2.5-bin.zip && \
    unzip gradle-2.5-bin.zip && \
    rm gradle-2.5-bin.zip

# Export some environment variables
ENV GRADLE_HOME=/usr/local/gradle-2.5
ENV PATH=$PATH:$GRADLE_HOME/bin
WORKDIR springboot
CMD [ "./gradlew", "bootRun" ]

```

2. docker build 

```
[root@ip-172-31-2-193 assignmentclicktail]# docker build -t springbootcode .
Sending build context to Docker daemon  163.5MB
Step 1/12 : FROM alpine:latest
 ---> e66264b98777
Step 2/12 : COPY springboot /springboot
 ---> Using cache
 ---> ec5a27cab3b2
Step 3/12 : RUN apk update
 ---> Using cache
 ---> 6896ceb5a51c
Step 4/12 : RUN apk add openjdk11
 ---> Using cache
 ---> 2b56f3ce303c
Step 5/12 : RUN apk add curl
 ---> Using cache
 ---> 6a2fb8339b8e
Step 6/12 : RUN apk add --no-cache bash
 ---> Using cache
 ---> 53bbd5cbf848
Step 7/12 : RUN apk add --upgrade zip
 ---> Using cache
 ---> 1a68fcf1c0a0
Step 8/12 : RUN     cd /usr/local &&     curl -L https://services.gradle.org/distributions/gradle-2.5-bin.zip -o gradle-2.5-bin.zip &&     unzip gradle-2.5-bin.zip &&     rm gradle-2.5-bin.zip
 ---> Running in aedb1e0bb6d0
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 42.5M  100 42.5M    0     0  33.6M      0  0:00:01  0:00:01 --:--:-- 44.6M
Archive:  gradle-2.5-bin.zip
   creating: gradle-2.5/
  inflating: gradle-2.5/getting-started.html
  inflating: gradle-2.5/LICENSE
  inflating: gradle-2.5/NOTICE
  inflating: gradle-2.5/changelog.txt
   creating: gradle-2.5/init.d/
  inflating: gradle-2.5/init.d/readme.txt
   creating: gradle-2.5/media/
  inflating: gradle-2.5/media/gradle-icon-512x512.png
  inflating: gradle-2.5/media/gradle-icon-16x16.png
  inflating: gradle-2.5/media/gradle.icns
  inflating: gradle-2.5/media/gradle-icon-128x128.png
  inflating: gradle-2.5/media/gradle-icon-256x256.png
  inflating: gradle-2.5/media/gradle-icon-48x48.png
  inflating: gradle-2.5/media/gradle-icon-24x24.png
  inflating: gradle-2.5/media/gradle-icon-64x64.png
  inflating: gradle-2.5/media/gradle-icon-32x32.png
   creating: gradle-2.5/bin/
  inflating: gradle-2.5/bin/gradle.bat
  inflating: gradle-2.5/bin/gradle
   creating: gradle-2.5/lib/
  inflating: gradle-2.5/lib/gradle-launcher-2.5.jar
  inflating: gradle-2.5/lib/gradle-wrapper-2.5.jar
  inflating: gradle-2.5/lib/gradle-base-services-2.5.jar
  inflating: gradle-2.5/lib/gradle-core-2.5.jar
  inflating: gradle-2.5/lib/gradle-cli-2.5.jar
  inflating: gradle-2.5/lib/gradle-tooling-api-2.5.jar
  inflating: gradle-2.5/lib/gradle-ui-2.5.jar
  inflating: gradle-2.5/lib/gradle-native-2.5.jar
  inflating: gradle-2.5/lib/slf4j-api-1.7.10.jar
  inflating: gradle-2.5/lib/guava-jdk5-17.0.jar
  inflating: gradle-2.5/lib/commons-lang-2.6.jar
  inflating: gradle-2.5/lib/groovy-all-2.3.10.jar
  inflating: gradle-2.5/lib/gradle-model-groovy-2.5.jar
  inflating: gradle-2.5/lib/gradle-model-core-2.5.jar
  inflating: gradle-2.5/lib/commons-collections-3.2.1.jar
  inflating: gradle-2.5/lib/ant-1.9.3.jar
  inflating: gradle-2.5/lib/asm-all-5.0.3.jar
  inflating: gradle-2.5/lib/commons-io-1.4.jar
  inflating: gradle-2.5/lib/jul-to-slf4j-1.7.10.jar
  inflating: gradle-2.5/lib/jcip-annotations-1.0.jar
  inflating: gradle-2.5/lib/gradle-messaging-2.5.jar
  inflating: gradle-2.5/lib/jarjar-1.3.jar
  inflating: gradle-2.5/lib/javax.inject-1.jar
  inflating: gradle-2.5/lib/gradle-base-services-groovy-2.5.jar
  inflating: gradle-2.5/lib/gradle-docs-2.5.jar
  inflating: gradle-2.5/lib/log4j-over-slf4j-1.7.10.jar
  inflating: gradle-2.5/lib/jcl-over-slf4j-1.7.10.jar
  inflating: gradle-2.5/lib/gradle-open-api-2.5.jar
  inflating: gradle-2.5/lib/gradle-resources-2.5.jar
  inflating: gradle-2.5/lib/native-platform-0.10.jar
  inflating: gradle-2.5/lib/jna-3.2.7.jar
  inflating: gradle-2.5/lib/ant-launcher-1.9.3.jar
  inflating: gradle-2.5/lib/jansi-1.2.1.jar
  inflating: gradle-2.5/lib/jaxen-1.1.jar
  inflating: gradle-2.5/lib/dom4j-1.6.1.jar
  inflating: gradle-2.5/lib/native-platform-osx-amd64-0.10.jar
  inflating: gradle-2.5/lib/native-platform-linux-amd64-0.10.jar
  inflating: gradle-2.5/lib/native-platform-osx-i386-0.10.jar
  inflating: gradle-2.5/lib/kryo-2.20.jar
  inflating: gradle-2.5/lib/native-platform-windows-amd64-0.10.jar
  inflating: gradle-2.5/lib/native-platform-linux-i386-0.10.jar
  inflating: gradle-2.5/lib/native-platform-freebsd-amd64-0.10.jar
  inflating: gradle-2.5/lib/native-platform-freebsd-i386-0.10.jar
  inflating: gradle-2.5/lib/native-platform-windows-i386-0.10.jar
  inflating: gradle-2.5/lib/objenesis-1.2.jar
  inflating: gradle-2.5/lib/minlog-1.2.jar
  inflating: gradle-2.5/lib/reflectasm-1.07-shaded.jar
   creating: gradle-2.5/lib/plugins/
  inflating: gradle-2.5/lib/plugins/gradle-plugins-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-code-quality-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-antlr-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-jetty-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-osgi-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-maven-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-ide-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-scala-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-announce-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-signing-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-ear-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-sonar-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-javascript-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-build-comparison-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-diagnostics-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-reporting-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-ivy-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-publish-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-platform-base-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-build-init-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-jacoco-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-language-jvm-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-platform-jvm-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-language-java-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-platform-native-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-language-groovy-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-language-scala-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-testing-native-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-ide-native-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-language-native-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-platform-play-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-resources-s3-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-tooling-api-builders-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-resources-sftp-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-resources-http-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-plugin-development-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-plugin-use-2.5.jar
  inflating: gradle-2.5/lib/plugins/gradle-dependency-management-2.5.jar
  inflating: gradle-2.5/lib/plugins/junit-4.12.jar
  inflating: gradle-2.5/lib/plugins/testng-6.3.1.jar
  inflating: gradle-2.5/lib/plugins/commons-cli-1.2.jar
  inflating: gradle-2.5/lib/plugins/jetty-6.1.25.jar
  inflating: gradle-2.5/lib/plugins/geronimo-annotation_1.0_spec-1.0.jar
  inflating: gradle-2.5/lib/plugins/jetty-annotations-6.1.25.jar
  inflating: gradle-2.5/lib/plugins/jsp-2.1-6.1.14.jar
  inflating: gradle-2.5/lib/plugins/jetty-plus-6.1.25.jar
  inflating: gradle-2.5/lib/plugins/servlet-api-2.5-20081211.jar
  inflating: gradle-2.5/lib/plugins/jetty-util-6.1.25.jar
  inflating: gradle-2.5/lib/plugins/pmaven-common-0.8-20100325.jar
  inflating: gradle-2.5/lib/plugins/pmaven-groovy-0.8-20100325.jar
  inflating: gradle-2.5/lib/plugins/maven-core-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/bndlib-2.1.0.jar
  inflating: gradle-2.5/lib/plugins/jatl-0.2.2.jar
  inflating: gradle-2.5/lib/plugins/sonar-batch-bootstrapper-2.9.jar
  inflating: gradle-2.5/lib/plugins/gson-2.2.4.jar
  inflating: gradle-2.5/lib/plugins/bcpg-jdk15on-1.51.jar
  inflating: gradle-2.5/lib/plugins/rhino-1.7R3.jar
  inflating: gradle-2.5/lib/plugins/simple-4.1.21.jar
  inflating: gradle-2.5/lib/plugins/bcprov-jdk15on-1.51.jar
  inflating: gradle-2.5/lib/plugins/httpclient-4.2.2.jar
  inflating: gradle-2.5/lib/plugins/nekohtml-1.9.14.jar
  inflating: gradle-2.5/lib/plugins/jsch-0.1.51.jar
  inflating: gradle-2.5/lib/plugins/aws-java-sdk-s3-1.9.19.jar
  inflating: gradle-2.5/lib/plugins/aws-java-sdk-kms-1.9.19.jar
  inflating: gradle-2.5/lib/plugins/aws-java-sdk-core-1.9.19.jar
  inflating: gradle-2.5/lib/plugins/jackson-core-2.3.2.jar
  inflating: gradle-2.5/lib/plugins/jackson-annotations-2.3.2.jar
  inflating: gradle-2.5/lib/plugins/jackson-databind-2.3.2.jar
  inflating: gradle-2.5/lib/plugins/joda-time-2.7.jar
  inflating: gradle-2.5/lib/plugins/ivy-2.2.0.jar
  inflating: gradle-2.5/lib/plugins/xbean-reflect-3.4.jar
  inflating: gradle-2.5/lib/plugins/aether-util-1.13.1.jar
  inflating: gradle-2.5/lib/plugins/aether-impl-1.13.1.jar
  inflating: gradle-2.5/lib/plugins/plexus-sec-dispatcher-1.3.jar
  inflating: gradle-2.5/lib/plugins/jsp-api-2.1-6.1.14.jar
  inflating: gradle-2.5/lib/plugins/core-3.1.1.jar
  inflating: gradle-2.5/lib/plugins/jetty-naming-6.1.25.jar
  inflating: gradle-2.5/lib/plugins/snakeyaml-1.6.jar
  inflating: gradle-2.5/lib/plugins/wagon-http-2.4.jar
  inflating: gradle-2.5/lib/plugins/maven-model-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/aether-connector-wagon-1.13.1.jar
  inflating: gradle-2.5/lib/plugins/plexus-classworlds-2.4.jar
  inflating: gradle-2.5/lib/plugins/maven-repository-metadata-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/maven-aether-provider-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/wagon-provider-api-2.4.jar
  inflating: gradle-2.5/lib/plugins/aether-spi-1.13.1.jar
  inflating: gradle-2.5/lib/plugins/jcommander-1.12.jar
  inflating: gradle-2.5/lib/plugins/bsh-2.0b4.jar
  inflating: gradle-2.5/lib/plugins/xercesImpl-2.9.1.jar
  inflating: gradle-2.5/lib/plugins/jcifs-1.3.17.jar
  inflating: gradle-2.5/lib/plugins/xml-apis-1.3.04.jar
  inflating: gradle-2.5/lib/plugins/maven-artifact-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/plexus-interpolation-1.14.jar
  inflating: gradle-2.5/lib/plugins/maven-settings-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/aether-api-1.13.1.jar
  inflating: gradle-2.5/lib/plugins/maven-settings-builder-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/maven-compat-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/maven-plugin-api-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/plexus-container-default-1.5.5.jar
  inflating: gradle-2.5/lib/plugins/wagon-http-shared4-2.4.jar
  inflating: gradle-2.5/lib/plugins/commons-codec-1.6.jar
  inflating: gradle-2.5/lib/plugins/httpcore-4.2.2.jar
  inflating: gradle-2.5/lib/plugins/plexus-cipher-1.7.jar
  inflating: gradle-2.5/lib/plugins/wagon-file-2.4.jar
  inflating: gradle-2.5/lib/plugins/maven-model-builder-3.0.4.jar
  inflating: gradle-2.5/lib/plugins/plexus-utils-2.0.6.jar
  inflating: gradle-2.5/lib/plugins/plexus-component-annotations-1.5.5.jar
  inflating: gradle-2.5/lib/plugins/hamcrest-core-1.3.jar
   creating: gradle-2.5/lib/plugins/sonar/
  inflating: gradle-2.5/lib/plugins/sonar/logback-classic-1.0.13.jar
  inflating: gradle-2.5/lib/plugins/sonar/logback-core-1.0.13.jar
Removing intermediate container aedb1e0bb6d0
 ---> 394898b01c04
Step 9/12 : ENV GRADLE_HOME=/usr/local/gradle-2.5
 ---> Running in bf6d55f6c46f
Removing intermediate container bf6d55f6c46f
 ---> 242a78c0374b
Step 10/12 : ENV PATH=$PATH:$GRADLE_HOME/bin
 ---> Running in 09d61b6b893d
Removing intermediate container 09d61b6b893d
 ---> cdeac876bc1b
Step 11/12 : WORKDIR springboot
 ---> Running in 6e2f0b7151e7
Removing intermediate container 6e2f0b7151e7
 ---> 58e464dd7bb6
Step 12/12 : CMD [ "./gradlew", "bootRun" ]
 ---> Running in 8409986fe778
Removing intermediate container 8409986fe778
 ---> 0b7d85d67b14
Successfully built 0b7d85d67b14
Successfully tagged springbootcode:latest
```
 

3. Verified if the images are created correctly 
```
 docker images
REPOSITORY       TAG       IMAGE ID       CREATED              SIZE
springbootcode   latest    0b7d85d67b14   About a minute ago   329MB
<none>           <none>    d11c3c1cedcd   2 hours ago          329MB
<none>           <none>    a10cab9e6cca   2 hours ago          279MB
<none>           <none>    15e6dede0f65   2 hours ago          279MB
<none>           <none>    f29ec1358f1a   2 hours ago          279MB
alpine           latest    e66264b98777   6 weeks ago          5.53MB
debian           jessie    3aaeab7a4777   15 months ago        129MB

```

4. Executed the image to verify its running correctly

```
 docker run -d -t -i -p 8080:8080 springbootcode
060898ca766e6e4e1ffe10ed8d339f782bcb7c55ec9d9f07b5b0dac297b5fa2e

```

5. Access the webserver from outside, used port forwarding to connect to container and verified logs

```
 docker logs -f 060898ca766e
Downloading https://services.gradle.org/distributions/gradle-7.4.2-bin.zip
...........10%...........20%...........30%...........40%...........50%...........60%...........70%...........80%...........90%...........100%

Welcome to Gradle 7.4.2!

Here are the highlights of this release:
 - Aggregated test and JaCoCo reports
 - Marking additional test source directories as tests in IntelliJ
 - Support for Adoptium JDKs in Java toolchains

For more details see https://docs.gradle.org/7.4.2/release-notes.html

Starting a Gradle Daemon (subsequent builds will be faster)
```

6. Check the application url on http://15.222.233.33:8080/

***************************************************************************************************

## **Phase 4: Creating the repository and push images, create helm charts**

1. Created the AWS ECR repository using command below
```
aws ecr create-repository --repository-name eks-assignment-ecr --image-scanning-configuration scanOnPush=true --region ca-central-1
{
    "repository": {
        "repositoryUri": "791155996298.dkr.ecr.ca-central-1.amazonaws.com/eks-assignment-ecr",
        "imageScanningConfiguration": {
            "scanOnPush": true
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        },
        "registryId": "791155996298",
        "imageTagMutability": "MUTABLE",
        "repositoryArn": "arn:aws:ecr:ca-central-1:791155996298:repository/eks-assignment-ecr",
        "repositoryName": "eks-assignment-ecr",
        "createdAt": 1657131600.0
    }
}

```

2. Tag the image and push it to the repo
```
docker tag springsampleserver:latest 281455864058.dkr.ecr.us-east-2.amazonaws.com/teja-assignment-ecr:latest
```

3. Perform the docker login

```
aws ecr get-login-password --region ca-central-1 | docker login --username AWS --password-stdin 791155996298.dkr.ecr.ca-central-1.amazonaws.com
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
[root@ip-172-31-2-193 assignmentclicktail]# docker tag eks-assignment-ecr:latest 791155996298.dkr.ecr.ca-central-1.amazonaws.com/eks-assignment-ecr:latest^C
[root@ip-172-31-2-193 assignmentclicktail]# docker tag springbootcode:latest 791155996298.dkr.ecr.ca-central-1.amazonaws.com/eks-assignment-ecr:latest

```

4. Pushing  the image to repo

```
[root@ip-172-31-2-193 assignmentclicktail]# docker push 791155996298.dkr.ecr.ca-central-1.amazonaws.com/eks-assignment-ecr:latest
The push refers to repository [791155996298.dkr.ecr.ca-central-1.amazonaws.com/eks-assignment-ecr]
c070e7026e40: Pushed
8d47eeed75dd: Pushed
bd1d9d38f5c9: Pushed
ed0344b57b82: Pushed
f686f5b73b88: Pushed
aa8d502ab9e0: Pushed
3254ec7296bb: Pushed
24302eb7d908: Pushed
latest: digest: sha256:c7b1877c88b0ade35b0ced95fdaf2d91747e84b414b0df5be4fbc90c68524273 size: 2004

```

***************************************************************************************************
## **Phase 5: Creating the Kubernetes object for the deployment, using Deployments**

1. Created the deployment yaml with follwing contents

```
 cat deployment-http.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: springsample-deployment
  labels:
    app: springsample
spec:
  replicas: 2
  selector:
    matchLabels:
      app: springsample
  template:
    metadata:
      labels:
        app: springsample
    spec:
      containers:
      - name: springsample
        image: 281455864058.dkr.ecr.us-east-2.amazonaws.com/teja-assignment-ecr:http-python
        stdin: true
        tty: true
        ports:
        - containerPort: 80
```

2. Expose the deployment to Load Balancer

```
cat loadbalancer.yaml
apiVersion: v1
kind: Service
metadata:
  name: springsample-service-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: springsample
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

```
3. Check if the application is accessible from outside world and PODs are running

```
kubectl get pods -l 'app=springsample' -o wide | awk {'print $1" " $3 " " $6'} | column -t
NAME                                    STATUS   IP
springsample-deployment-59bf6466b6-qr762  Running  172.31.33.246
springsample-deployment-59bf6466b6-zqfzb  Running  172.31.7.0


kubectl get service/springsample-service-loadbalancer |  awk {'print $1" " $2 " " $4 " " $5'} | column -t
NAME                             TYPE          EXTERNAL-IP                                                              PORT(S)
springsample-service-loadbalancer  LoadBalancer  a71f383d39a5749718ad6efe4d516eca-1978462511.us-east-2.elb.amazonaws.com  80:32138/TCP



```

4. Application url is working on http://a6085a721161a4b05a9d0482ba71864f-1087627329.ca-central-1.elb.amazonaws.com/


**************************************************************************************************************


 
```
