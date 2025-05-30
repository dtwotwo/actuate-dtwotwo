﻿package motion.actuators;


class MethodActuator<T> extends SimpleActuator<T, T> {
	var currentParameters:Array<Dynamic>;
	var tweenProperties:Dynamic;

	public function new(target:T, duration:Float, properties:Dynamic) {
		currentParameters = new Array<Dynamic>();
		tweenProperties = {};

		super(target, duration, properties);

		if (!Reflect.hasField(properties, "start"))
			this.properties.start = new Array<Dynamic>();

		if (!Reflect.hasField(properties, "end"))
			this.properties.end = this.properties.start;

		for (i in 0...this.properties.start.length)
			currentParameters.push(this.properties.start[i]);
	}

	override function apply():Void {
		callMethod(target, properties.end);
	}

	override function complete(sendEvent = true):Void {
		if (initialized) {
			for (i in 0...properties.start.length)
				currentParameters[i] = Reflect.field(tweenProperties, "param" + i);
			callMethod(target, currentParameters);
		}

		super.complete(sendEvent);
	}

	override function initialize():Void {
		var details:PropertyDetails<T>;
		var propertyName:String;
		var start:Dynamic;

		for (i in 0...properties.start.length) {
			propertyName = "param" + i;
			start = properties.start[i];

			Reflect.setField(tweenProperties, propertyName, start);

			if (Std.isOfType(start, Float) || Std.isOfType(start, Int)) {
				details = new PropertyDetails(tweenProperties, propertyName, start, properties.end[i] - start);
				propertyDetails.push(details);
			}
		}

		detailsLength = propertyDetails.length;
		initialized = true;
	}


	override function update(currentTime:Float):Void {
		super.update(currentTime);

		if (active && !paused) {
			for (i in 0...properties.start.length)
				currentParameters[i] = Reflect.field(tweenProperties, "param" + i);
			callMethod(target, currentParameters);
		}
	}
}