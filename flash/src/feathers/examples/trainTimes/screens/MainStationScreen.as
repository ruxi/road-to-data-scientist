package feathers.examples.trainTimes.screens
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Header;
	import feathers.controls.List;
	import feathers.controls.Screen;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.examples.trainTimes.controls.StationListItemRenderer;
	import feathers.examples.trainTimes.model.StationData;
	import feathers.examples.trainTimes.themes.TrainTimesTheme;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	[Event(name="complete",type="starling.events.Event")]
	
	public class MainStationScreen extends Screen
	{
		public static const CHILD_STYLE_NAME_STATION_LIST:String = "stationList";
		public static const CHILD_STYLE_NAME_STATION_LIST_ITEM_RENDERER:String = "stationListItemRenderer";
		public static const CHILD_STYLE_NAME_STATION_LIST_FIRST_ITEM_RENDERER:String = "stationListFirstItemRenderer";
		public static const CHILD_STYLE_NAME_STATION_LIST_LAST_ITEM_RENDERER:String = "stationListLastItemRenderer";
		
		private static const FIRST_ITEM_RENDERER_ID:String = "station-list-first-item-renderer";
		private static const LAST_ITEM_RENDERER_ID:String = "station-list-last-item-renderer";
		
		public function MainStationScreen()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		public var selectedDepartureStation:StationData;
		public var selectedDestinationStation:StationData;
		
		private var _departureHeader:Header;
		private var _destinationHeader:Header;
		private var _backButton:Button;
		private var _stationList:List;
		
		private var _headerTween:Tween;
		private var _buttonGroup:ButtonGroup;
		
		override protected function initialize():void
		{
			this._stationList = new List();
			this._stationList.styleNameList.add(CHILD_STYLE_NAME_STATION_LIST);
			this._stationList.dataProvider = new ListCollection(
				[
					new StationData("1.Fundamentals"),
					new StationData("2.Statistics"),
					new StationData("3.Programming"),
					new StationData("4.Machine Learning"),
					new StationData("5.TextMining/NLP"),
					new StationData("6.Visualization"),
					new StationData("7.Big Data"),
					new StationData("8.Data Ingestion"),
					new StationData("9.Data Munging"),
					new StationData("10.Toolbox"),
				])
			this._stationList.itemRendererFactory = this.createItemRenderer;
			this._stationList.setItemRendererFactoryWithID(FIRST_ITEM_RENDERER_ID, this.createFirstItemRenderer);
			this._stationList.setItemRendererFactoryWithID(LAST_ITEM_RENDERER_ID, this.createLastItemRenderer);
			this._stationList.factoryIDFunction = this.factoryIDFunction;
			this.addChild(this._stationList);
			
			this._backButton = new Button();
			this._backButton.visible = false;
			this._backButton.addEventListener(Event.TRIGGERED, backButton_triggeredHandler);
			
			this._departureHeader = new Header();
			this._departureHeader.title = "Choose Departure Station";
			this.addChild(this._departureHeader);
			
			this._destinationHeader = new Header();
			this._destinationHeader.title = "Choose Destination Station";
			this._destinationHeader.leftItems = new <DisplayObject>
				[
					this._backButton
				];
			this.addChild(this._destinationHeader);
		}
		
		override protected function draw():void
		{
			this._departureHeader.width = this.actualWidth;
			this._destinationHeader.width = this.actualWidth;
			
			var currentHeader:Header;
			if(this.selectedDepartureStation)
			{
				currentHeader = this._destinationHeader;
				this._destinationHeader.x = 0;
				this._destinationHeader.visible = true;
				this._departureHeader.x = this.actualWidth;
				this._departureHeader.visible = false;
			}
			else
			{
				currentHeader = this._departureHeader;
				this._destinationHeader.x = -this.actualWidth;
				this._destinationHeader.visible = false;
				this._departureHeader.x = 0;
				this._departureHeader.visible = true;
			}
			
			currentHeader.validate();
			this._stationList.y = currentHeader.height;
			this._stationList.width = this.actualWidth;
			this._stationList.height = this.actualHeight - this._stationList.y;
		}
		
		private function factoryIDFunction(item:Object, index:int):String
		{
			if(index === 0)
			{
				return FIRST_ITEM_RENDERER_ID;
			}
			else if(index === this._stationList.dataProvider.length - 1)
			{
				return LAST_ITEM_RENDERER_ID;
			}
			return null;
		}
		
		private function createItemRenderer():StationListItemRenderer
		{
			var itemRenderer:StationListItemRenderer = new StationListItemRenderer();
			itemRenderer.styleNameList.add(CHILD_STYLE_NAME_STATION_LIST_ITEM_RENDERER);
			itemRenderer.confirmCallback = this.stationList_onConfirm;
			itemRenderer.isInDestinationPhase = false;
			return itemRenderer;
		}
		
		private function createFirstItemRenderer():StationListItemRenderer
		{
			var itemRenderer:StationListItemRenderer = new StationListItemRenderer();
			itemRenderer.styleNameList.add(CHILD_STYLE_NAME_STATION_LIST_FIRST_ITEM_RENDERER);
			itemRenderer.confirmCallback = this.stationList_onConfirm;
			itemRenderer.isInDestinationPhase = false;
			return itemRenderer;
		}
		
		private function createLastItemRenderer():StationListItemRenderer
		{
			var itemRenderer:StationListItemRenderer = new StationListItemRenderer();
			itemRenderer.styleNameList.add(CHILD_STYLE_NAME_STATION_LIST_LAST_ITEM_RENDERER);
			itemRenderer.confirmCallback = this.stationList_onConfirm;
			itemRenderer.isInDestinationPhase = false;
			return itemRenderer;
		}
		
		private function onBackButton():void
		{
			this.selectedDepartureStation.isDepartingFromHere = false;
			var index:int = this._stationList.dataProvider.getItemIndex(this.selectedDepartureStation);
			this._stationList.dataProvider.updateItemAt(index);
			this._stationList.selectedItem = this.selectedDepartureStation;
			this.selectedDepartureStation = null;
			this._backButton.visible = false;
			this._departureHeader.title = "Choose Departure Station";
			this._stationList.itemRendererProperties.isInDestinationPhase = false;
			
			this._departureHeader.visible = true;
			if(this._headerTween)
			{
				Starling.juggler.remove(this._headerTween);
				this._headerTween = null;
			}
			this._headerTween = new Tween(this._departureHeader, 0.4, Transitions.EASE_OUT);
			this._headerTween.animate("x", 0);
			this._headerTween.onUpdate = headerTween_onUpdate;
			this._headerTween.onComplete = headerTween_onDestinationHideComplete;
			Starling.juggler.add(this._headerTween);
		}
		
		private function stationList_onConfirm():void
		{
			if(this.selectedDepartureStation)
			{
				this.selectedDestinationStation = StationData(this._stationList.selectedItem);
				this.dispatchEventWith(Event.COMPLETE);
				return;
			}
			this.selectedDepartureStation = StationData(this._stationList.selectedItem);
			this.selectedDepartureStation.isDepartingFromHere = true;
			
			this._departureHeader.title = "Choose Destination Station";
			this._backButton.visible = true;
			
			this._stationList.selectedIndex = -1;
			this._stationList.itemRendererProperties.isInDestinationPhase = true;
			
			this._destinationHeader.visible = true;
			if(this._headerTween)
			{
				Starling.juggler.remove(this._headerTween);
				this._headerTween = null;
			}
			this._headerTween = new Tween(this._departureHeader, 0.4, Transitions.EASE_OUT);
			this._headerTween.animate("x", this.actualWidth);
			this._headerTween.onUpdate = headerTween_onUpdate;
			this._headerTween.onComplete = headerTween_onDestinationShowComplete;
			Starling.juggler.add(this._headerTween);
		}
		
		private function headerTween_onUpdate():void
		{
			this._destinationHeader.x = this._departureHeader.x - this.actualWidth;
		}
		
		private function headerTween_onDestinationShowComplete():void
		{
			this._departureHeader.visible = false;
			this._headerTween = null;
		}
		
		private function headerTween_onDestinationHideComplete():void
		{
			this._destinationHeader.visible = false;
			this._headerTween = null;
		}
		
		private function addedToStageHandler(event:Event):void
		{
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler, false, 0, true);
		}
		
		private function removedFromStageHandler(event:Event):void
		{
			Starling.current.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler);
		}
		
		private function backButton_triggeredHandler(event:Event):void
		{
			this.onBackButton();
		}
		
		private function nativeStage_keyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.BACK && this.selectedDepartureStation)
			{
				event.preventDefault();
				this.onBackButton();
			}
		}
		private function button_triggeredHandler(event:Event):void
		{
			var button:Button = Button(event.currentTarget);
			trace(button.label + " triggered.");
		}
	}
}

