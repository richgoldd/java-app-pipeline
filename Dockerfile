FROM openjdk:11

WORKDIR /usr/app/

COPY target/*.jar spring-boot-docker-app.jar   

ENTRYPOINT ["java", "-jar", "spring-boot-docker-app.jar"]
