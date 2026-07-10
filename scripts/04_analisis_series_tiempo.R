###SERIES DE TIEMPO Y ANÁLISIS DE MORA CARTERA
# 1. Simulamos 3 años de recaudo mensual (36 meses)
set.seed(123)
meses <- seq(as.Date("2022-01-01"), by = "month", length.out = 36)

# Tendencia de fondo (crecimiento leve)
tendencia <- seq(100, 160, length.out = 36)

# Pico estacional en julio (mes 7, 19, 31 en la secuencia)
estacionalidad <- rep(0, 36)
meses_julio <- which(format(meses, "%m") == "07")
estacionalidad[meses_julio] <- 40  # boost por predial/vehículos

# Ruido aleatorio
ruido <- rnorm(36, mean = 0, sd = 5)

recaudo <- tendencia + estacionalidad + ruido
cartera <- data.frame(mes = meses, recaudo = recaudo)

# Graficamos
plot(cartera$mes, cartera$recaudo, type = "o", col = "darkgreen",
     main = "Recaudo mensual simulado (con pico en julio)",
     xlab = "Mes", ylab = "Recaudo")
abline(v = meses[meses_julio], col = "red", lty = 2)

#2. SEPARAR TENDENCIA Y ESTACIONALIDAD CON DECOMPOSE()
#R necesita que los datos estén en formato de serie de tiempo (ts), indicando que la frecuencia es 12 (mensual)

# Convertir a objeto ts (serie de tiempo), empezando en enero 2022, frecuencia mensual
serie_ts <- ts(cartera$recaudo, start = c(2022, 1), frequency = 12)

# Descomponer en tendencia, estacionalidad y residuo (ruido)
descomposicion <- decompose(serie_ts)

# Graficar los 4 paneles: original, tendencia, estacionalidad, residuo
plot(descomposicion)

#4 KP1 COLLECTION RATE
# Supongamos que la cartera total asignada para cobro era de 200 (unidades) cada mes
cartera$cartera_total <- 200
cartera$collection_rate <- (cartera$recaudo / cartera$cartera_total) * 100

# Ver los primeros meses
head(cartera[, c("mes", "recaudo", "collection_rate")])

# Graficar la tasa de recaudo en el tiempo
plot(cartera$mes, cartera$collection_rate, type = "o", col = "blue",
     main = "Collection Rate (%) mensual",
     xlab = "Mes", ylab = "Collection Rate (%)")

# ajustar directorio
setwd("C:/Users/krito/Documents/CAROL/EMPLEO/PORTAFOLIO/portfolio-tax-collection-bogota")

# Guardar el script de R (esto lo haces manualmente: File > Save As, dentro de scripts/)

# Guardar el data frame procesado en outputs/
saveRDS(cartera, file = "outputs/cartera_procesada.rds")
write.csv(cartera, "outputs/cartera_procesada.csv", row.names = FALSE)

# Guardar las gráficas en plots/
png("plots/decomposicion_series_tiempo.png", width = 800, height = 600)
plot(descomposicion)
dev.off()

png("plots/collection_rate_mensual.png", width = 800, height = 600)
plot(cartera$mes, cartera$collection_rate, type = "o", col = "blue",
     main = "Collection Rate (%) mensual", xlab = "Mes", ylab = "Collection Rate (%)")
dev.off()
