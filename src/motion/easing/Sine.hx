﻿package motion.easing;

/**
 * @author Joshua Granick
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */
class Sine {
	public static var easeIn(default, null):IEasing = new SineEaseIn();
	public static var easeInOut(default, null):IEasing = new SineEaseInOut();
	public static var easeOut(default, null):IEasing = new SineEaseOut();
}

class SineEaseIn implements IEasing {
	public function new() {}

	public function calculate(k:Float):Float {
		return 1 - Math.cos(k * (Math.PI * .5));
	}

	public function ease(t:Float, b:Float, c:Float, d:Float):Float {
		return -c * Math.cos(t / d * (Math.PI * .5)) + c + b;
	}
}

class SineEaseInOut implements IEasing {
	public function new() {}

	public function calculate(k:Float):Float {
		return - (Math.cos(Math.PI * k) - 1) * .5;
	}

	public function ease(t:Float, b:Float, c:Float, d:Float):Float {
		return -c * .5 * (Math.cos(Math.PI * t / d) - 1) + b;
	}
}

class SineEaseOut implements IEasing {
	public function new() {}

	public function calculate(k:Float):Float {
		return Math.sin(k * (Math.PI * .5));
	}

	public function ease(t:Float, b:Float, c:Float, d:Float):Float {
		return c * Math.sin(t / d * (Math.PI * .5)) + b;
	}
}