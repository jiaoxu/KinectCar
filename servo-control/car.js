var net = require('net'); 
var index = 0; 
var mySocket;

var server = net.createServer(function (socket) {
	mySocket=socket;
	index++;
	new Client(index,socket); 
}); 
server.listen(8124, '192.168.1.8');
 
console.log('server started...');

var five = require("johnny-five"),
  board, servo;

board = new five.Board();

board.on("ready", function() {

  servo = new five.Servo({
    pin: 6,
    range:[60,110]
  });

  board.repl.inject({
    servo: servo
  });
  servo.center();
});

console.log('servo ready...');

function Client(index,socket) {
	var myIndex = index;
	socket.setEncoding("utf8");
    socket.on('data',function(data){
		var _data=data.slice(0,data.length-1);
    var _power=data.slice(0,1);
    // if(_power=='+'&&motor_output['c']>-100)
    // {
    //   motor_output['c']-=20;
    //   motor_output['d']-=20;
    //   startEv3();
    // }else if(_power=='-'&&motor_output['c']<0)
    // {
    //   motor_output['c']+=20;
    //   motor_output['d']+=20;
    //   startEv3();
    // }else
    // {
    //   servo.move(Number(_data));
    // }
    servo.move(Number(_data)/2+60);
  });  
} 

// function startEv3(){
//     var output = currentTarget.getOutputSequence(motor_output["a"],motor_output["b"],motor_output["c"],motor_output["d"]);  
//     currentTarget.sp.write(output);
// }

// // ----------------Ev3---------------
// var Ev3 = require ("./module/Ev3.js");
// var Ev3_base = Ev3.base;

// var motor_on_focus = "a";
// var motor_output = {"a": 0, "b":0,"c":0, "d":0};
       
// var robot = new Ev3_base("/dev/tty.EV3-SerialPort");

// var currentTarget;
// robot.connect(function()
// {
//     robot.start_program(example_program);
// });

// var example_program = function(target){
//   currentTarget=target;
// };
