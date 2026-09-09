import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { SwaggerModule, DocumentBuilder } from "@nestjs/swagger";
import helmet from "helmet";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(helmet());
  app.enableCors({
    origin: process.env.CORS_ORIGIN?.split(",") || ["http://localhost:3000"],
    credentials: true,
  });
  app.setGlobalPrefix("api/v1");
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  const config = new DocumentBuilder()
    .setTitle("Druvatara Guardian API")
    .setDescription(
      "Backend API for Druvatara Guardian Digital Safety Platform",
    )
    .setVersion("1.0")
    .addBearerAuth()
    .addTag("Authentication", "Auth endpoints")
    .addTag("Families", "Family management")
    .addTag("Children", "Child profiles")
    .addTag("Devices", "Device management")
    .addTag("Policies", "Policy management")
    .addTag("Usage", "Usage tracking")
    .addTag("Location", "Location & geofencing")
    .addTag("Alerts", "Safety alerts")
    .addTag("Reports", "Reporting")
    .addTag("TARA", "AI Assistant")
    .addTag("Subscriptions", "Billing & subscriptions")
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("docs", app, document);

  const httpAdapter = app.getHttpAdapter();
  httpAdapter.get("/", (req, res) => {
    res.redirect("/docs");
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🚀 Server running on http://localhost:${port}`);
  console.log(`📚 API docs available at http://localhost:${port}/docs`);
}

bootstrap();
