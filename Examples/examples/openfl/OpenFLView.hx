package examples.openfl;

import dragonbones.animation.WorldClock;
import dragonbones.factorys.ArmatureFactory;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

/**
 * @author SlavaRa
 */
class OpenFLView extends Sprite{

	public static function main() Lib.current.addChild(new OpenFLView());
	
	public function new() {
		super();
		if(stage != null) {
			onStageAddedToStage();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, onStageAddedToStage);
		}
	}
	
	var factory:ArmatureFactory;
	
	function onStageAddedToStage(?_) {
		removeEventListener(Event.ADDED_TO_STAGE, onStageAddedToStage);
		configureStage();
		initialize();
	}
	
	inline function configureStage() {
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
	}
	
	inline function initialize() {
		#if flash
		var url = "../../../Resources/dragonbones_png/character.png";
		#elseif (cpp || neko)
		var url = "../../../../Resources/dragonbones_png/character.png";
		#end
		var urlRequest = new URLRequest(url);
		var urlLoader = new URLLoader();
		urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.load(urlRequest);
	}
	
	function onUrlLoaderComplete(event:Event) {
		var urlLoader = cast(event.target, URLLoader);
		urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
		
		factory = new ArmatureFactory();
		factory.onDataParsed.addOnce(onFactoryDataParsed);
		factory.parseData(cast(urlLoader.data, ByteArray));
	}
	
	function onFactoryDataParsed() {
		var x:Float = 100;
		var y:Float = 150;
		
		for (i in 0...10) {
			var armature = factory.buildArmature("CharacterAnimations");
			var display = cast(armature.displayContainer, DisplayObject);
			display.x = x;
			display.y = y;
			x += display.width + 10;
			if((x + display.width) >= stage.stageWidth) {
				x = 100;
				y += display.height + 10;
			}
			armature.animation.gotoAndPlay("Idle", -1, -1, true);
			addChild(display);
			WorldClock.instance.add(armature);
		}
		
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	function onEnterFrame(_) WorldClock.instance.advanceTime( -1);
}