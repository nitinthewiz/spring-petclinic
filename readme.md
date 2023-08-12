# Jenkins + Spring PetClinic

## Introduction
This repo brings the Spring PetClinic sample application to Jenkins CI/CD. We use a Jenkinsfile to build the application, test it, containerize it using a Dockerfile and then push the docker image out to JFrog Artifactory. We also scan the docker image for known vulnerabilities with JFrog Xray, and publish build information to Artifactory as well.

## Changes from base repo
The following files have changed from the base spring-petclinic repo - 
1. Jenkinsfile - A Jenkinsfile automates the task of creating a Jenkins pipeline. We can list out all the steps that we need to perform in Jenkins and expect the existing Jenkins infrastructure to implement the pipeline. It does assume that the required plugins and credentials are already setup in Jenkins.
2. Dockerfile - The original repo has a spring-boot based mechanism to create a Docker image using this software. However, this Dockerfile adds the ability to create a docker image using Jenkins and also gives us a chance to make changes to the final Docker image before it is deployed.
3. pom.xml - Some dependencies are not available in the repositories listed in the original pom file. Adding JCenter lets us install these missing dependencies.
4. readme.md - This file. It contains information about this endeavor, details about changes, and a running commentary on my discovery process as I went about completing this work.

## Relevant links to files
Jenkinsfile - https://github.com/nitinthewiz/spring-petclinic/blob/main/Jenkinsfile \
Dockerfile - https://github.com/nitinthewiz/spring-petclinic/blob/main/Dockerfile \
Readme - https://github.com/nitinthewiz/spring-petclinic/blob/main/readme.md \
Artifactory - https://nitin4jfrog.jfrog.io/

## How to run the project
1. First, setup Artifactory. Either locally or online. With the online version, you get excellent instructions to create a repository for docker images and connect it to CI/CD platforms like Jenkins. When you get to the instructions for Jenkins, move to the next step.
2. Second, setup Jenkins. Make sure this installation of Jenkins has access to a docker installation to run docker CLI to build and create containers.
3. Next, install the required plugins - you will need the Docker Pipeline plugin and the JFrog plugin.
4. Once the plugins are installed, follow the instructions on Artifactory to setup the JFrog plugin, including credentials, configuration, and installing the JFrog CLI.
5. Now, you're ready to create a "New Item" in Jenkins. Head to the dashboard and click on "New Item". Pick a name for this task and select the Pipeline type.
6. On the configuration page, select GitHub Project and set the URL to this repo (https://github.com/nitinthewiz/spring-petclinic/). Then, under Pipeline, select "Pipeline script from SCM", select Git, and set the repo URL to this same repo. Also, change the branch from "\*/master" to "\*/main". Hit Save.
7. Now, your project is ready to be built.
8. Hit "Build Now" and watch as the repo is checked out, the tools are installed and the build, test, and deploy stages (build, scan, push docker image; publish build info) are executed.
9. Once the build completes successfully, head to your artifactory page (mine is [this](https://nitin4jfrog.jfrog.io/)) and check out - 
    - Packages, which contain the versioned docker images along with docker pull instructions
    - Builds, which contain all the builds you've triggered and which have successfully uploaded data to Artifactory. This includes Xray data, build info, release history, etc.
    - Artifacts, which include manifest files and checksums.
10. Now, you can pull down the docker image and deploy it, as shown in the next section.

## How to run the docker image
1. Once the docker image shows up on Artifactory, you can pull it down using docker or a variety of other container installation and management tools (such as portainer, podman, podman desktop, Rancher Desktop).
2. The Packages section will show the docker images with versions. Click through a version to see Docker layers, Xray information, and a docker pull command.
3. You can pull the current latest docker image for this application using the following command - \
    `docker pull nitin4jfrog.jfrog.io/docker-local/spring-petclinic:1.0.1`
4. Once you've pulled the image, you can use the following docker run command to get it running - \
    `docker run -p 8081:8080 nitin4jfrog.jfrog.io/docker-local/spring-petclinic:1.0.1` \
    This will run the docker image with the exposed port 8082, while the internal port of the application is 8080.
5. Alternatively, you can use the following snippet with docker compose or portainer - 
    ```
    version: '3.7'
    services:
      jenkins:
        image: nitin4jfrog.jfrog.io/docker-local/spring-petclinic:1.0.1
        ports:
          - 8081:8080
        container_name: nitin4frog-spring
    ```
    This specifically creates a container named nitin4frog-spring and exposes the application on port 8081.
6. You can now visit the application at `http://localhost:8081` in your browser.

## Notes on discovery
1. Deployed local Jenkins on docker - jenkins/jenkins:lts-jdk11
2. Added a freestyle project called "petclinique" and pointed it to the petclinic repo - https://github.com/nitinthewiz/spring-petclinic
3. Discovered that some dependencies are missing from the repositories mentioned in the pom.xml file
4. Added jcenter as a repository to pom.xml
5. Discovered that pom.xml specifies minimum Java version as 17, while jenkins LTS is Java 11.
6. Changed Jenkins docker container to use Java 17
7. Got a successful run of "./mvnw package"
8. Added Jenkinsfile and pushed to repo, created a pipeline job in Jenkins and pointed to the repo's Jenkinsfile
9. Jenkinsfile now points to the main branch of the repo, not the default, which is master
10. Added Dockerfile, testing it
11. Added plugins to upload docker images to artifactory, updated Jenkinsfile accordingly
12. Observed uploaded artifacts on Artifactory. Downloaded and installed application using `docker run` and `docker compose`.


# ---- End of custom notes

# Spring PetClinic Sample Application [![Build Status](https://github.com/spring-projects/spring-petclinic/actions/workflows/maven-build.yml/badge.svg)](https://github.com/spring-projects/spring-petclinic/actions/workflows/maven-build.yml)

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/spring-projects/spring-petclinic) [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=7517918)




## Understanding the Spring Petclinic application with a few diagrams
<a href="https://speakerdeck.com/michaelisvy/spring-petclinic-sample-application">See the presentation here</a>

## Running petclinic locally
Petclinic is a [Spring Boot](https://spring.io/guides/gs/spring-boot) application built using [Maven](https://spring.io/guides/gs/maven/) or [Gradle](https://spring.io/guides/gs/gradle/). You can build a jar file and run it from the command line (it should work just as well with Java 17 or newer):


```
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
./mvnw package
java -jar target/*.jar
```

You can then access petclinic at http://localhost:8080/

<img width="1042" alt="petclinic-screenshot" src="https://cloud.githubusercontent.com/assets/838318/19727082/2aee6d6c-9b8e-11e6-81fe-e889a5ddfded.png">

Or you can run it from Maven directly using the Spring Boot Maven plugin. If you do this, it will pick up changes that you make in the project immediately (changes to Java source files require a compile as well - most people use an IDE for this):

```
./mvnw spring-boot:run
```

> NOTE: If you prefer to use Gradle, you can build the app using `./gradlew build` and look for the jar file in `build/libs`.

## Building a Container

There is no `Dockerfile` in this project. You can build a container image (if you have a docker daemon) using the Spring Boot build plugin:

```
./mvnw spring-boot:build-image
```

## In case you find a bug/suggested improvement for Spring Petclinic
Our issue tracker is available [here](https://github.com/spring-projects/spring-petclinic/issues)


## Database configuration

In its default configuration, Petclinic uses an in-memory database (H2) which
gets populated at startup with data. The h2 console is exposed at `http://localhost:8080/h2-console`,
and it is possible to inspect the content of the database using the `jdbc:h2:mem:testdb` url.
 
A similar setup is provided for MySQL and PostgreSQL if a persistent database configuration is needed. Note that whenever the database type changes, the app needs to run with a different profile: `spring.profiles.active=mysql` for MySQL or `spring.profiles.active=postgres` for PostgreSQL.

You can start MySQL or PostgreSQL locally with whatever installer works for your OS or use docker:

```
docker run -e MYSQL_USER=petclinic -e MYSQL_PASSWORD=petclinic -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=petclinic -p 3306:3306 mysql:8.0
```

or

```
docker run -e POSTGRES_USER=petclinic -e POSTGRES_PASSWORD=petclinic -e POSTGRES_DB=petclinic -p 5432:5432 postgres:15.2
```

Further documentation is provided for [MySQL](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources/db/mysql/petclinic_db_setup_mysql.txt)
and for [PostgreSQL](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources/db/postgres/petclinic_db_setup_postgres.txt).

Instead of vanilla `docker` you can also use the provided `docker-compose.yml` file to start the database containers. Each one has a profile just like the Spring profile:

```
$ docker-compose --profile mysql up
```

or

```
$ docker-compose --profile postgres up
```

## Test Applications

At development time we recommend you use the test applications set up as `main()` methods in `PetClinicIntegrationTests` (using the default H2 database and also adding Spring Boot devtools), `MySqlTestApplication` and `PostgresIntegrationTests`. These are set up so that you can run the apps in your IDE and get fast feedback, and also run the same classes as integration tests against the respective database. The MySql integration tests use Testcontainers to start the database in a Docker container, and the Postgres tests use Docker Compose to do the same thing.

## Compiling the CSS

There is a `petclinic.css` in `src/main/resources/static/resources/css`. It was generated from the `petclinic.scss` source, combined with the [Bootstrap](https://getbootstrap.com/) library. If you make changes to the `scss`, or upgrade Bootstrap, you will need to re-compile the CSS resources using the Maven profile "css", i.e. `./mvnw package -P css`. There is no build profile for Gradle to compile the CSS.

## Working with Petclinic in your IDE

### Prerequisites
The following items should be installed in your system:
* Java 17 or newer (full JDK, not a JRE).
* [git command line tool](https://help.github.com/articles/set-up-git)
* Your preferred IDE 
  * Eclipse with the m2e plugin. Note: when m2e is available, there is an m2 icon in `Help -> About` dialog. If m2e is
  not there, follow the install process [here](https://www.eclipse.org/m2e/)
  * [Spring Tools Suite](https://spring.io/tools) (STS)
  * [IntelliJ IDEA](https://www.jetbrains.com/idea/)
  * [VS Code](https://code.visualstudio.com)

### Steps:

1) On the command line run:
    ```
    git clone https://github.com/spring-projects/spring-petclinic.git
    ```
2) Inside Eclipse or STS:
    ```
    File -> Import -> Maven -> Existing Maven project
    ```

    Then either build on the command line `./mvnw generate-resources` or use the Eclipse launcher (right click on project and `Run As -> Maven install`) to generate the css. Run the application main method by right-clicking on it and choosing `Run As -> Java Application`.

3) Inside IntelliJ IDEA
    In the main menu, choose `File -> Open` and select the Petclinic [pom.xml](pom.xml). Click on the `Open` button.

    CSS files are generated from the Maven build. You can build them on the command line `./mvnw generate-resources` or right-click on the `spring-petclinic` project then `Maven -> Generates sources and Update Folders`.

    A run configuration named `PetClinicApplication` should have been created for you if you're using a recent Ultimate version. Otherwise, run the application by right-clicking on the `PetClinicApplication` main class and choosing `Run 'PetClinicApplication'`.

4) Navigate to Petclinic

    Visit [http://localhost:8080](http://localhost:8080) in your browser.


## Looking for something in particular?

|Spring Boot Configuration | Class or Java property files  |
|--------------------------|---|
|The Main Class | [PetClinicApplication](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/PetClinicApplication.java) |
|Properties Files | [application.properties](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/resources) |
|Caching | [CacheConfiguration](https://github.com/spring-projects/spring-petclinic/blob/main/src/main/java/org/springframework/samples/petclinic/system/CacheConfiguration.java) |

## Interesting Spring Petclinic branches and forks

The Spring Petclinic "main" branch in the [spring-projects](https://github.com/spring-projects/spring-petclinic)
GitHub org is the "canonical" implementation based on Spring Boot and Thymeleaf. There are
[quite a few forks](https://spring-petclinic.github.io/docs/forks.html) in the GitHub org
[spring-petclinic](https://github.com/spring-petclinic). If you are interested in using a different technology stack to implement the Pet Clinic, please join the community there.


## Interaction with other open source projects

One of the best parts about working on the Spring Petclinic application is that we have the opportunity to work in direct contact with many Open Source projects. We found bugs/suggested improvements on various topics such as Spring, Spring Data, Bean Validation and even Eclipse! In many cases, they've been fixed/implemented in just a few days.
Here is a list of them:

| Name | Issue |
|------|-------|
| Spring JDBC: simplify usage of NamedParameterJdbcTemplate | [SPR-10256](https://jira.springsource.org/browse/SPR-10256) and [SPR-10257](https://jira.springsource.org/browse/SPR-10257) |
| Bean Validation / Hibernate Validator: simplify Maven dependencies and backward compatibility |[HV-790](https://hibernate.atlassian.net/browse/HV-790) and [HV-792](https://hibernate.atlassian.net/browse/HV-792) |
| Spring Data: provide more flexibility when working with JPQL queries | [DATAJPA-292](https://jira.springsource.org/browse/DATAJPA-292) |


# Contributing

The [issue tracker](https://github.com/spring-projects/spring-petclinic/issues) is the preferred channel for bug reports, features requests and submitting pull requests.

For pull requests, editor preferences are available in the [editor config](.editorconfig) for easy use in common text editors. Read more and download plugins at <https://editorconfig.org>. If you have not previously done so, please fill out and submit the [Contributor License Agreement](https://cla.pivotal.io/sign/spring).

# License

The Spring PetClinic sample application is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).

[spring-petclinic]: https://github.com/spring-projects/spring-petclinic
[spring-framework-petclinic]: https://github.com/spring-petclinic/spring-framework-petclinic
[spring-petclinic-angularjs]: https://github.com/spring-petclinic/spring-petclinic-angularjs 
[javaconfig branch]: https://github.com/spring-petclinic/spring-framework-petclinic/tree/javaconfig
[spring-petclinic-angular]: https://github.com/spring-petclinic/spring-petclinic-angular
[spring-petclinic-microservices]: https://github.com/spring-petclinic/spring-petclinic-microservices
[spring-petclinic-reactjs]: https://github.com/spring-petclinic/spring-petclinic-reactjs
[spring-petclinic-graphql]: https://github.com/spring-petclinic/spring-petclinic-graphql
[spring-petclinic-kotlin]: https://github.com/spring-petclinic/spring-petclinic-kotlin
[spring-petclinic-rest]: https://github.com/spring-petclinic/spring-petclinic-rest
