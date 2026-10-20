package com.ecoair;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class EcoAirApplication {
    public static void main(String[] args) {
        System.out.println("Started EcoAirApplication");
        SpringApplication.run(EcoAirApplication.class, args);
    }
}
