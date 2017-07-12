dofile("PwmSvr_PCA9685.lua")
PwmSvr.begin()
PwmSvr.setPWMFreq(60)
for pin=0,15 do
	for r=150,400 do
		PwmSvr.setPWM(pin, 0, r)
		tmr.wdclr()
	end
end