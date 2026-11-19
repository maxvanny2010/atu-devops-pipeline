# Stage 1: Build and test
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

COPY pom.xml .
RUN mvn --batch-mode --no-transfer-progress dependency:go-offline

COPY src ./src
RUN mvn --batch-mode --no-transfer-progress clean verify

# Stage 2: Extract Spring Boot layers
FROM eclipse-temurin:24-jre-noble AS extract

WORKDIR /app

COPY --from=build /app/target/task-manager-0.0.1-SNAPSHOT.jar application.jar

RUN java -Djarmode=tools -jar application.jar extract --layers --destination extracted

# Stage 3: Runtime
FROM eclipse-temurin:24-jre-noble AS runtime

WORKDIR /app

COPY --from=extract /app/extracted/dependencies/ ./
COPY --from=extract /app/extracted/spring-boot-loader/ ./
COPY --from=extract /app/extracted/snapshot-dependencies/ ./
COPY --from=extract /app/extracted/application/ ./

RUN mkdir -p /app/tmp && chown -R 10001:10001 /app

USER 10001:10001

EXPOSE 8080

ENTRYPOINT ["java", "-Djava.io.tmpdir=/app/tmp", "-jar", "application.jar"]