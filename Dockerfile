FROM openjdk:11-jre-slim
WORKDIR /app
COPY target/shopping-cart-0.0.1-SNAPSHOT.jar /app/shopping-cart.jar
EXPOSE 8070
CMD ["java", "-jar", "shopping-cart.jar"]
