int i = 0;

void setup() {
  Serial.begin(9600);
  pinMode(13, OUTPUT);

}

void loop() {
  if(Serial.available() > 0){
    i++;
    Serial.parseInt();
    if(i>2){
      Serial.println(25);
      i = 0;
    } 
  }
}
