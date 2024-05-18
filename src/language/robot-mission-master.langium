grammar RobotMissionMaster


entry Model: 
    (robots+=Robot | environments+=Environment | missions+=Mission)*;

Statement: 
    Mission | Robot | Environment;

Mission: 
    Environment | 
    Task | 
    Robot Block;

Macro:          
    definition=[Definition:ID] '(' (arguments+=Expression (',' argumentss+=Expression)*)? ')';
Definition:    
    'definition' name=ID '(' (parameters+=Parameter (',' parameters+=Parameter)*)? ')' Block;


Task: Description | Action | MultipleRobotActions | Time;

Description: 
    "Description" ":" description=STRING;
Actions: 
    "Actions" ":" actions+=Action*;
MultipleRobotActions: 
    "MultipleRobotActions" ":" multiplyiRobotActions+=Action*;
Time: 
    "Time" ":" time=Expression*;


// Robot
Robot: 
    PossibleActions | 
    RobotType | 
    Position | 
    StartPosition | 
    Battery 
    Block;

PossibleActions:    
    "PossibleActions" ":" actions+=Action*;
StartPosition:    
    "StartPosition" ":" startPosition=Position*;
Battery:    
    "Battery" ":" battery=Time;
terminal RobotType: 
    "LandRobot" | "Boat" | "UnderwaterDrone" | "AirDrone";


// Environment 
Environment: 
    Size | 
    Obstacle | 
    WorldObject 
    Block;

WorldObject: 
    ID | 
    Position | 
    Size;

Obstacle: 
    Position | 
    ObstacleType | 
    Size;

terminal ObstacleType: "ObstacleType" ":" ("Land" | "Water" | "Air" | "Weather");


Action: 
    Move | Turn | MoveTo | Wait | Pickup | Drop | WorkAction;

Move: 
    "Move" "(" direction=Vector "," length=Expression ")";
MoveTo: 
    "MoveTo" position=Position;
Turn: 
    "Turn" ":" ("ToAngle" ":"  angle=Expression | "ToDirection" ":" direction=Vector);
Wait: 
    "Wait"  ":" time=Expression;
Pickup: 
    "Object" ":" WorldObject;
Drop: 
    "Drop" ":" WorldObject;
WorkAction: 
    "Description" description=STRING;


Size: 
    "Size" "(" length=Expression "," width=Expression "," height=Expression ")";
Position: 
    "Position" "(" x=Expression "," y=Expression "," z=Expression ")";
Vector: 
    "Vector" "(" x=Expression "," y=Expression "," z=Expression ")";


fragment Block: '{' body+=Statement* '}';

Parameter: name=ID;

Expression: Add;

Add  infers Expression: 
    Multiply     ({infer BinExpression.e1=current} op=('+'|'-') e2=Multiply)*;
Multiply infers Expression: 
    PrimaryExpression ({infer BinExpression.e1=current} op=('*'|'/') e2=PrimaryExpression)*;

// Primary Expressionessions
PrimaryExpression: Literal | Reference | Group | NegativeExpression;

Literal:                
    value=NUMBER;
Reference:              
    value=[Parameter:ID];
Group:                  
    "(" group=Expression ")";
NegativeExpression:     
    "-" negativeExpression=Expression;


// Terminals
terminal HEX returns string:        
    /#(\d|[a-fA-F]){3,6}/;
terminal ID returns string:         
    /[_a-zA-Z][\w_]*/;
terminal STRING returns string:      
    /[_a-zA-Z][\w_]*/;
terminal NUMBER returns number:       
    /(?:(?:-?[0-9]+)?\.[0-9]+)|-?[0-9]+/;

// Ignore whitespaces
hidden terminal WS:                 
    /\s+/;
// // and /* */ comments
hidden terminal ML_COMMENT:         
    /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT:         
    /\/\/[^\n\r]*/;
