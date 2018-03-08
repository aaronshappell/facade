import processing.video.*;
import processing.serial.*;

PImage canvas;
Capture cap;

Serial port;

//pixelateEffect vars
int pixelateKernalSize = 1;
//colorEffect vars
int colorValue = 0;
//glitchEffect vars
int glitchShiftAmount = 0;
int glitchSliceHeight = 1;

void setup(){
    size(640, 480);
    canvas = createImage(width, height, RGB);
    cap = new Capture(this, width, height);
    cap.start();
    //port = new Serial(this, Serial.list()[0], 9600);
}

void draw(){
    /*
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
    */
    if(cap.available()){
        cap.read();
        canvas.copy(cap, 0, 0, cap.width, cap.height, 0, 0, cap.width, cap.height);
        colorEffect(colorValue);
        pixelateEffect(pixelateKernalSize);
    }
    glitchEffect(glitchShiftAmount, glitchSliceHeight);
    image(canvas, 0, 0);
}

void pixelateEffect(int kernalSize){
    canvas.loadPixels();
    for(int y = 0; y < height; y += kernalSize){
        for(int x = 0; x < width; x += kernalSize){
            int avgR = 0;
            int avgG = 0;
            int avgB = 0;
            for(int sy = y; sy < y + kernalSize; sy++){
                if(sy >= height){
                    break;
                }
                for(int sx = x; sx < x + kernalSize; sx++){
                    if(sx >= width){
                        break;
                    }
                    avgR += (canvas.pixels[sy * width + sx] >> 16) & 0xFF;
                    avgG += (canvas.pixels[sy * width + sx] >> 8) & 0xFF;
                    avgB += canvas.pixels[sy * width + sx] & 0xFF;
                }
            }
            avgR /= kernalSize * kernalSize;
            avgG /= kernalSize * kernalSize;
            avgB /= kernalSize * kernalSize;
            for(int sy = y; sy < y + kernalSize; sy++){
                if(sy >= height){
                    break;
                }
                for(int sx = x; sx < x + kernalSize; sx++){
                    if(sx >= width){
                        break;
                    }
                    canvas.pixels[sy * width + sx] = color(avgR, avgG, avgB);
                }
            }
        }
    }
    canvas.updatePixels();
}

void colorEffect(int value){
    canvas.loadPixels();
    for(int y = 0; y < height; y++){
        for(int x = 0; x < width; x++){
            canvas.pixels[y * width + x] = canvas.pixels[y * width + x] + value;
        }
    }
    canvas.updatePixels();
}

void glitchEffect(int shiftAmount, int sliceHeight){
    canvas.loadPixels();
    int rowCounter = 0;
    if(shiftAmount < 0){
        rowCounter = 1;
        shiftAmount = Math.abs(shiftAmount);
    }
    for(int y = 0; y < height; y += sliceHeight){
        for(int sy = y; sy < y + sliceHeight; sy++){
            if(sy >= height){
                break;
            }
            for(int i = 0; i < shiftAmount; i++){
                shift(canvas.pixels, rowCounter % 2 == 0, sy * width, sy * width + width - 1);
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