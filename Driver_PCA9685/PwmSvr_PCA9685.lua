PwmSvr={
	id=0,			PCA9685_SUBADR1=0x2,	LED0_ON_L=0x6,	ALLLED_ON_L=0xFA,
	pinSCL=1,		PCA9685_SUBADR2=0x3,	LED0_ON_H=0x7,	ALLLED_ON_H=0xFB,
	pinSDA=2,		PCA9685_SUBADR3=0x4,	LED0_OFF_L=0x8,	ALLLED_OFF_L=0xFC,
	_i2caddr=0x40,	PCA9685_MODE1=0x0,		LED0_OFF_H=0x9,	ALLLED_OFF_H=0xFD,
	addr=nil,		PCA9685_PRESCALE=0xFE
}
function PwmSvr.read8(addr)
	i2c.start(PwmSvr.id)
	i2c.address(PwmSvr.id, PwmSvr._i2caddr,i2c.TRANSMITTER)
	i2c.write(PwmSvr.id,addr)
	i2c.stop(PwmSvr.id)
	i2c.start(PwmSvr.id)
	i2c.address(PwmSvr.id, PwmSvr._i2caddr,i2c.RECEIVER)
	local c=i2c.read(PwmSvr.id,1)
	i2c.stop(PwmSvr.id)
	return string.byte(c)
end
function PwmSvr.write8(addr,d)
	i2c.start(PwmSvr.id)
	i2c.address(PwmSvr.id, PwmSvr._i2caddr ,i2c.TRANSMITTER)
	i2c.write(PwmSvr.id,addr,d)
	i2c.stop(PwmSvr.id)
end
function PwmSvr.reset()
	PwmSvr.write8(PwmSvr.PCA9685_MODE1,0x0)
end
function PwmSvr.begin()
	i2c.setup(PwmSvr.id, PwmSvr.pinSDA, PwmSvr.pinSCL, i2c.SLOW)
	PwmSvr.reset()
end
function PwmSvr.setPWMFreq(freq)
	local prescale=math.ceil((25000000/4096)/(freq*0.9)+0.5)
	local oldmode = PwmSvr.read8(PwmSvr.PCA9685_MODE1)
	local newmode =bit.bor(bit.band(oldmode,0x7F),0x10)
	PwmSvr.write8(PwmSvr.PCA9685_MODE1,newmode)
	PwmSvr.write8(PwmSvr.PCA9685_PRESCALE,prescale)
	PwmSvr.write8(PwmSvr.PCA9685_MODE1,oldmode)
	for i=0,6000 do tmr.wdclr() end
	PwmSvr.write8(PwmSvr.PCA9685_MODE1, bit.bor(oldmode,0xa1))
end
function PwmSvr.setPWM(num,on,off)
	i2c.start(PwmSvr.id)
	i2c.address(PwmSvr.id, PwmSvr._i2caddr ,i2c.TRANSMITTER)
	i2c.write(PwmSvr.id
		,PwmSvr.LED0_ON_L+4*num
		,bit.band(on,0xff)
		,bit.rshift(on,8)
		,bit.band(off,0xff)
		,bit.rshift(off,8)
	)
	i2c.stop(PwmSvr.id)
end
function PwmSvr.setPin(num,val,invert)
	if(val>4095) then val=4095 end
	if(invert) then
		if(val==0) then
			PwmSvr.setPWM(num, 4096, 0)
		elseif(val==4095) then
			PwmSvr.setPWM(num, 0, 4096)
		else
			PwmSvr.setPWM(num, 0, 4095-val)
		end
	else
		if(val==4095) then
			PwmSvr.setPWM(num, 4096, 0)
		elseif(val==0) then
			PwmSvr.setPWM(num, 0, 4096)
		else
			PwmSvr.setPWM(num, 0, val)
		end
	end
	
end
