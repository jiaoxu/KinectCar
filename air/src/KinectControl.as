package
{
    import com.as3nui.nativeExtensions.air.kinect.Kinect;
    import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
    import com.as3nui.nativeExtensions.air.kinect.data.User;
    import com.as3nui.nativeExtensions.air.kinect.events.DeviceEvent;
    import com.as3nui.nativeExtensions.air.kinect.events.DeviceInfoEvent;

    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.net.XMLSocket;
    import flash.text.TextField
    import flash.utils.Timer;
    import flash.display.StageDisplayState;

    [SWF(backgroundColor="0xcfcfcf",width=1000,height=800)]
    public class KinectControl extends MovieClip
    {
        private var _kinect : Kinect;
        private var _debugger : KinectDebugger;
        private var _actionManager : ActionManager;
        private var _textField : TextField;

        public function KinectControl()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.nativeWindow.visible = true;
            stage.frameRate = 60;
            stage.displayState=StageDisplayState.FULL_SCREEN_INTERACTIVE;

            initText();
            initSocket();

            if(Kinect.isSupported())
            {
                init();
            }else
            {
                _textField.text='Kinect No Support!';
            }
        }

        private function initText():void
        {
            _textField = new TextField();
            _textField.width=1000;
            _textField.height=200;
            TextStyle.apply(_textField, "_sans", "",'',80,'0xff0000');
            addChild(_textField);
        }

        private var ev3Socket:XMLSocket;
        private var servoSocket:XMLSocket;
        private var speed:int=-10;
        private var angle:Number=93;
        private var block:int=1;
        private function initSocket():void
        {
            ev3Socket=new XMLSocket();
            ev3Socket.addEventListener(Event.CONNECT,ev3SocketConnectHandler);
            ev3Socket.connect('192.168.1.4',8124);
            servoSocket=new XMLSocket();
            servoSocket.addEventListener(Event.CONNECT,servoSocketConnectHandler);
            servoSocket.connect('192.168.1.8',8124);
        }

        private var timer:Timer;
        private function servoSocketConnectHandler(e:Event):void
        {
            _textField.text='Socket Connect Success!';

            timer=new Timer(100);
            timer.addEventListener(TimerEvent.TIMER,onTimerHandler);
            timer.start();
        }
        private function ev3SocketConnectHandler(e:Event):void
        {
            ev3Socket.send(speed);
        }

        private function init() : void
        {
            _kinect = Kinect.getDevice();
            _kinect.addEventListener(DeviceInfoEvent.INFO,onInfoHandler);

            var settings : KinectSettings = new KinectSettings();
            settings.skeletonEnabled = true;
            _kinect.start(settings);
            _kinect.addEventListener(DeviceEvent.STARTED, _started);
            _debugger = new KinectDebugger(_kinect, true, true, false, false);
            addChild(_debugger);
            _actionManager = new ActionManager(stage.frameRate);
        }

        private function onInfoHandler(e:DeviceInfoEvent):void
        {
            trace(e.message+':')
        }

        private function _started(event : DeviceEvent) : void
         {
            _kinect.removeEventListener(DeviceEvent.STARTED, _started);
            addEventListener(Event.ENTER_FRAME, _enterFrame);
        }

        private function _enterFrame(event : Event) : void
        {
            if(_kinect.users.length != 0)
            {
                var uniqueUser : User = _getUniqueUser(_kinect.users);

                _debugger.draw(uniqueUser);

                _actionManager.compute(uniqueUser);
            }

            if (_kinect != null) {
                drawUsers(_kinect.usersWithSkeleton);
            }
        }

        private var _height:Number=0;
        private function drawUsers(users:Vector.<User>):void {
            for each(var user:User in users) {

                var x1:Number=user.leftHand.position.world.x;
                var x2:Number=user.rightHand.position.world.x;
                var y1:Number=user.leftHand.position.world.y;
                var y2:Number=user.rightHand.position.world.y;
                var n:Number=Math.atan2(y2-y1,x2-x1);
                var n2:Number=n*180/Math.PI;
                if(n2<50&&n2>-50)
                {
                    angle=Math.floor(n2)/2;
                }

                _height=(y1+y2)/2;
            }
        }

        private function onTimerHandler(e:TimerEvent):void
        {
            _textField.text =_height+'';

            if(_height>400)
            {
                ev3Socket.send('-100');
            }else if(_height<400&&_height>200)
            {
                ev3Socket.send('-60');
            }else if(_height<200&&_height>0)
            {
                ev3Socket.send('-40');
            }else if(_height<0&&_height>-200)
            {
                ev3Socket.send('-20');
            }else
            {
                ev3Socket.send('0');
            }
            servoSocket.send(String((angle+25)*2))
        }

        private function _getUniqueUser(usersWithSkeleton : Vector.<User>) : User 
        {
            var i : int = 0;
            var userNumber : int = usersWithSkeleton.length;
            var user : User = usersWithSkeleton[i];

            if (userNumber > 1) {
                for (i = 0; i < userNumber; i++)
                {
                    if(usersWithSkeleton[i].position.world.z < user.position.world.z)
                    {
                        user = usersWithSkeleton[i];
                    }
                }
            }
            return user;
        }
    }

}