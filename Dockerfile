FROM bellsoft/liberica-runtime-container:jdk-all-17-slim-musl

EXPOSE 8080

# copy jar into image
COPY target/*.jar /home/*.jar

# run application with this command line 
ENTRYPOINT ["java","-jar","/home/*.jar"]