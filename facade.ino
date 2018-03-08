long currentTime;
long previousTime;

int pixelateKernalSize;
int colorValue;
int glitchShiftAmount;
int glitchSliceHeight;

void setup() {
    Serial.begin(9600);
}

void loop() {
    pixelateKernalSize = (int) map(analogRead(0), 0, 1023, 1, 50);
    colorValue = (int) map(analogRead(1), 0, 1023, -250, 250);
    glitchShiftAmount = (int) map(analogRead(2), 0, 1023, -40, 40);
    glitchSliceHeight = (int) map(analogRead(3), 0, 1023, 1, 200);
    currentTime = millis();
    if(currentTime - previousTime >= 20){
        previousTime = currentTime;
        Serial.print(pixelateKernalSize, DEC);
        Serial.print(",");
        Serial.print(colorValue, DEC);
        Serial.print(",");
        Serial.print(glitchShiftAmount, DEC);
        Serial.print(",");
        Serial.print(glitchSliceHeight, DEC);
        Serial.print(",");
        Serial.print("|");
    }
    delay(100);
}
