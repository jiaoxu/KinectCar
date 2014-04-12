var Ev3 = require ("./module/Ev3.js");
var Ev3_base = Ev3.base;

var motor_on_focus = "a";
var motor_output = {"a": 0, "b":0,"c":0, "d":0};

var example_program_motor = function(target){
	
	_target=target;
	var stdin = process.openStdin(); 
	var stdin = process.stdin;

	stdin.setRawMode( true );
	stdin.resume();

	stdin.setEncoding( 'utf8' );
	
};
var _target;

var robot = new Ev3_base("/dev/tty.EV3-SerialPort");

robot.connect(function(){
	robot.start_program(example_program_motor); 
});

/////SOCKET/////
var net = require('net'); 
var index = 0; 
var mySocket;

var server = net.createServer(function (socket) {
  mySocket=socket;
  index++;
  new Client(index,socket); 
}); 
server.listen(8124, '192.168.1.4');
 
console.log('server started...');

function Client(index,socket) {
  var myIndex = index;
  socket.setEncoding("utf8");
    socket.on('data',function(data){
    var _data=data.slice(0,data.length-1);

      motor_output['c']=Number(_data);
      motor_output['d']=Number(_data);

    startMotor();
  });  
} 

function startMotor(){
    var output = _target.getOutputSequence(motor_output["a"],motor_output["b"],motor_output["c"],motor_output["d"]);
    _target.sp.write( output,function(){});
}
