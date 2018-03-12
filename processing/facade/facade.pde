import processing.video.*;
import processing.serial.*;

PImage canvas;
Capture cap;

Serial port;

int pixelateKernalSize = 1;
int colorValue = 0;
int glitchShiftAmount = 0;
int glitchSliceHeight = 1;

void setup(){
    size(1280, 960);
    cap = new Capture(this, 640, 480);
    canvas = createImage(width, height, RGB);
    cap.start();
    port = new Serial(this, Serial.list()[0], 9600);
}

void draw(){
    if(port.available() > 0){
        String data = port.readStringUntil('|');
        if(data != null){
            data = trim(data);
            println(data);
            int buff[] = int(split(data, ','));
            if(buff.length == 5){
                pixelateKernalSize = buff[0];
                colorValue = buff[1];
                glitchShiftAmount = buff[2];
                glitchSliceHeight = buff[3];
            }
        }
    }
    if(cap.available()){
        cap.read();
        canvas.copy(cap, 0, 0, cap.width, cap.height, 0, 0, canvas.width, canvas.height);
        colorEffect(colorValue);
        pixelateEffect(pixelateKernalSize);
    }
    glitchEffect(glitchShiftAmount, glitchSliceHeight);
    image(canvas, 0, 0);
}

void pixelateEffect(int kernalSize){
    canvas.loadPixels();
    for(int y = 0; y < canvas.height; y += kernalSize){
        for(int x = 0; x < canvas.width; x += kernalSize){
            int avgR = 0;
            int avgG = 0;
            int avgB = 0;
            for(int sy = y; sy < y + kernalSize; sy++){
                if(sy >= canvas.height){
                    break;
                }
                for(int sx = x; sx < x + kernalSize; sx++){
                    if(sx >= canvas.width){
                        break;
                    }
                    avgR += (canvas.pixels[sy * canvas.width + sx] >> 16) & 0xFF;
                    avgG += (canvas.pixels[sy * canvas.width + sx] >> 8) & 0xFF;
                    avgB += canvas.pixels[sy * canvas.width + sx] & 0xFF;
                }
            }
            avgR /= kernalSize * kernalSize;
            avgG /= kernalSize * kernalSize;
            avgB /= kernalSize * kernalSize;
            for(int sy = y; sy < y + kernalSize; sy++){
                if(sy >= canvas.height){
                    break;
                }
                for(int sx = x; sx < x + kernalSize; sx++){
                    if(sx >= canvas.width){
                        break;
                    }
                    canvas.pixels[sy * canvas.width + sx] = color(avgR, avgG, avgB);
                }
            }
        }
    }
    canvas.updatePixels();
}

void colorEffect(int value){
    canvas.loadPixels();
    for(int y = 0; y < canvas.height; y++){
        for(int x = 0; x < canvas.width; x++){
            canvas.pixels[y * canvas.width + x] = canvas.pixels[y * canvas.width + x] + value;
        }
    }
    canvas.updatePixels();
}

void glitchEffect(int shiftAmount, int sliceHeight){
    if(shiftAmount != 0){
        shiftAmount += (Math.random() * shiftAmount) -shiftAmount;
    }
    canvas.loadPixels();
    int rowCounter = 0;
    if(shiftAmount < 0){
        rowCounter = 1;
        shiftAmount = Math.abs(shiftAmount);
    }
    for(int y = 0; y < canvas.height; y += sliceHeight){
        for(int sy = y; sy < y + sliceHeight; sy++){
            if(sy >= canvas.height){
                break;
            }
            for(int i = 0; i < shiftAmount; i++){
                shift(canvas.pixels, rowCounter % 2 == 0, sy * canvas.width, sy * canvas.width + canvas.width - 1);
            }
        }
        rowCounter++;
    }
    canvas.updatePixels();
}

//Shifts a given sub section of an array right for even row and left for odd row
void shift(color[] array, boolean evenRow, int start, int end){
    color temp;
    if(evenRow){
        temp = array[end];
        for(int i = end; i > start + 1; i--){
            array[i] = array[i - 1];
        }
        array[start] = temp;
    } else{
        temp = array[start];
        for(int i = start; i < end - 1; i++){
            array[i] = array[i + 1];
        }
        array[end] = temp;
    }
}