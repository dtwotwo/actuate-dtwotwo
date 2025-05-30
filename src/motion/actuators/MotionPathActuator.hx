﻿package motion.actuators;

import motion.MotionPath;

class MotionPathActuator<T> extends SimpleActuator<T, T> {
	public function new(target:T, duration:Float, properties:Dynamic) {
		super(target, duration, properties);
	}

	override function apply():Void {
		for (propertyName in Reflect.fields(properties)) {
			#if (haxe_209 || haxe3)
			if (Reflect.hasField(target, propertyName)) Reflect.setField(target, propertyName, cast(Reflect.field(properties, propertyName), IComponentPath).end);
			else Reflect.setProperty(target, propertyName, cast(Reflect.field(properties, propertyName), IComponentPath).end);
			#else
			Reflect.setField(target, propertyName, cast(Reflect.field(properties, propertyName), IComponentPath).end);
			#end
		}
	}

	override function initialize():Void {
		var details:PropertyPathDetails<T>;
		var path:IComponentPath;

		for (propertyName in Reflect.fields(properties)) {
			path = cast(Reflect.field(properties, propertyName), IComponentPath);

			if (path != null) {
				var isField = true;

				#if (haxe_209 || haxe3)
				#if !hl
				if (Reflect.hasField(target, propertyName)) {
					path.start = Reflect.field(target, propertyName);
				} else
				#end
				{
					isField = false;
					path.start = Reflect.getProperty(target, propertyName);
				}
				#else
				path.start = Reflect.field(target, propertyName);
				#end

				details = new PropertyPathDetails(target, propertyName, path, isField);
				propertyDetails.push(details);
			}
		}

		detailsLength = propertyDetails.length;
		initialized = true;
	}

	override function update(currentTime:Float):Void {
		if (!paused) {
			var details:PropertyPathDetails<T>;
			var easing:Float;

			var tweenPosition = (currentTime - timeOffset) / duration;

			if (tweenPosition > 1) tweenPosition = 1;
			if (!initialized) initialize();

			if (!special) {
				easing = _ease.calculate(tweenPosition);

				for (details in propertyDetails) {
					if (details.isField) Reflect.setField(details.target, details.propertyName, cast(details, PropertyPathDetails<Dynamic>).path.calculate(easing));
					else {
						#if (haxe_209 || haxe3)
						Reflect.setProperty(details.target, details.propertyName, cast(details, PropertyPathDetails<Dynamic>).path.calculate(easing));
						#end
					}
				}
			} else {
				easing = !_reverse ? _ease.calculate(tweenPosition) : _ease.calculate(1 - tweenPosition);

				for (details in propertyDetails) {
					if (!_snapping) {
						if (details.isField) Reflect.setField(details.target, details.propertyName, cast(details, PropertyPathDetails<Dynamic>).path.calculate(easing));
						else {
							#if (haxe_209 || haxe3)
							Reflect.setProperty(details.target, details.propertyName, cast(details, PropertyPathDetails<Dynamic>).path.calculate(easing));
							#end
						}
					} else {
						if (details.isField) Reflect.setField(details.target, details.propertyName, Math.round(cast(details, PropertyPathDetails<Dynamic>).path.calculate(easing)));
						else {
							#if (haxe_209 || haxe3)
							Reflect.setProperty(details.target, details.propertyName, Math.round(cast(details, PropertyPathDetails<Dynamic>).path.calculate(easing)));
							#end
						}
					}
				}
			}

			if (tweenPosition == 1) {
				if (_repeat == 0) {
					active = false;

					if (toggleVisible && getField(target, "alpha") == 0)
						setField(target, "visible", false);

					complete(true);
					return;
				} else {
					if (_onRepeat != null) callMethod(_onRepeat, _onRepeatParams);

					if (_reflect) _reverse = !_reverse;

					startTime = currentTime;
					timeOffset = startTime + _delay;

					if (_repeat > 0) _repeat--;
				}
			}
			if (sendChange) change();
		}
	}
}

#if !haxe3
import com.eclecticdesignstudio.motion.MotionPath;
#end

class PropertyPathDetails<T> extends PropertyDetails<T> {
	public var path:IComponentPath;

	public function new (target:T, propertyName:String, path:IComponentPath, isField = true) {
		super(target, propertyName, 0, 0, isField);
		this.path = path;
	}
}