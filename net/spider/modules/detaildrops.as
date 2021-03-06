package net.spider.modules{
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.text.TextFormat;
    import net.spider.main;
	import net.spider.handlers.ClientEvent;
	import net.spider.handlers.DrawEvent;
	import net.spider.handlers.SFSEvent;
	import net.spider.handlers.optionHandler;
	import flash.filters.*;
	import net.spider.draw.*;
	
	public class detaildrops extends MovieClip{

		public static function onToggle():void{
			if(optionHandler.detaildrop){
				itemArchive = new Vector.<Object>();
			}else{
				itemArchive = null;
			}
		}

		public static var itemArchive:Vector.<Object>;
        public static function onExtensionResponseHandler(e:*):void{
			if(!optionHandler.detaildrop)
				return;
            var dID:*;
            var protocol:* = e.params.type;
            if (protocol == "json")
                {
                    var resObj:* = e.params.dataObj;
                    var cmd:* = resObj.cmd;
                    switch (cmd)
                    {
                        case "dropItem":
							for (dID in resObj.items)
								if(resObj.items[dID].sName == null){
									if(!itemExists(main.Game.world.invTree[dID].sName))
										itemArchive.push(main.Game.copyObj(main.Game.world.invTree[dID]));
								}else if(!itemExists(resObj.items[dID].sName)){
									itemArchive.push(main.Game.copyObj(resObj.items[dID]));
								}
                        	break;
                    }
                }
        }

		public static function itemExists(item:String):Boolean{
			for each(var t_item:* in itemArchive)
				if(t_item.sName == item)
					return true;
			return false;
		}

		public static function isOwned(isHouse:Boolean, itemID:*):Boolean{
			for each(var item:* in ((isHouse) ? main.Game.world.myAvatar.houseitems : main.Game.world.myAvatar.items)){
				if(item.ItemID == itemID)
					return true;
			}
			if(main.Game.world.bankinfo.isItemInBank(itemID))
				return true;
			return false;
		}

        public static function onFrameUpdate():void{
			if(!optionHandler.detaildrop || !main.Game.sfc.isConnected || (main.Game.ui.dropStack.numChildren < 1))
				return;
			for(var i:int = 0; i < main.Game.ui.dropStack.numChildren; i++){
				try{
					var mcDrop:* = (main.Game.ui.dropStack.getChildAt(i) as MovieClip);
					if(getQualifiedClassName(mcDrop) != "DFrame2MC")
						continue;
					if(!mcDrop.cnt.bg.getChildByName("flag")){
						var sName:String = mcDrop.cnt.strName.text.replace(/ x[0-9]/g, "");
						for each(var item:* in itemArchive){
							if(item.sName != null && item.sName == sName){
								if(item.bCoins == 1){
									var glowFilter:* = new GlowFilter(0xF6CA2A, 1, 8, 8, 2, 1, false, false);
									mcDrop.filters = [glowFilter];
								}
								if(item.bUpg){
									var txtFormat:TextFormat = mcDrop.cnt.strName.defaultTextFormat;
									txtFormat.color = 0xFCC749;
									mcDrop.cnt.strName.setTextFormat(txtFormat);
								}
								if(isOwned(item.bHouse, item.ItemID)){
									trace("register " + itemArchive.length);
									var t_check:detailedCheck = new detailedCheck();
									t_check.width = mcDrop.cnt.icon.width;
									t_check.height = mcDrop.cnt.icon.height;
									t_check.x = 0;
									t_check.y = 0;
									mcDrop.cnt.icon.addChild(t_check);
								}
								//mcDrop.cnt.icon.addEventListener(MouseEvent.CLICK, onPreview(item), false, 0, true); --causing crashes
								var flag:mcCoin = new mcCoin();
								flag.visible = false;
								flag.name = "flag";
								mcDrop.cnt.bg.addChild(flag);
							}
						}
						itemArchive.length = 0;
					}
				}catch(exception){
					trace("Error handling drops: " + exception);
				}
			}
		}
		
		public static function onPreview(itemObj:*):Function{
			return function(e:MouseEvent):void {
				if(main.Game.ui.getChildByName("renderPreview"))
					main.Game.ui.removeChild(main.Game.ui.getChildByName("renderPreview"));
				var dRenderObj:* = new dRender(itemObj);
				dRenderObj.name = "renderPreview";
				main.Game.ui.addChild(dRenderObj);
			};
		}
	}
	
}
