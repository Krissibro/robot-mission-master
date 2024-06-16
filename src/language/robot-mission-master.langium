grammar RobotMissionMaster


entry Model: 
    (instances += Instance)*;    

Instance:
    Mission | 
    Environment | 
    Robot |
    WorldObject |
    Obstacle; 


// Environment 
Environment:
    "Environment" "{" 
        ID
        SizeProperty &
        Objects &
        Obstacles
    "}";

Objects:
    "Objects" "{"
        objects+=WorldObject*
    "}";

WorldObject:
    "WorldObject" "{" 
        ID
        PositionProperty &  
        SizeProperty &
        Weight
    "}";

Obstacles:
    "Obstacles" "{"
        obstacles+=Obstacle*
    "}";

Obstacle:
    "Obstacle" "{"
        ID
        PositionProperty &
        ObstacleType &
        SizeProperty
    "}";

ObstacleType:
    "ObstacleType" ":" obstacleType=("Land" | "Water" | "Air" | "Weather");



// Robot
Robot: 
    "Robot" "{"
        ID
        RobotType &
        Battery &
        Capacity 
    "}";

Battery:    
    "Battery" ":" battery=Expression;
RobotType: 
    "RobotType" ":" robotType=("Land" | "SurfaceWater" | "Underwater" | "Air");
Capacity:
    "Capacity" ":" capacity=Expression;


Action: 
    Move | Turn | MoveTo | Wait | Pickup | Drop | "ReturnToStart" "(" ")";

Move: 
    "Move" "(" direction=VectorProperty "," length=Length ")";
MoveTo: 
    "Position" "("position=Position ")";
// ReturnToStart:
//    "ReturnToStart" "(" position=[Mission:UNIQUE]? ")";
Turn: 
   "Turn" "(" (angle=Angle | direction=Vector) ")";
Wait: 
   "Wait" "(" time=Expression ")";
Pickup: 
    "Pickup" "(" pickupObject=[WorldObject:UNIQUE] ")";
Drop: 
   "Drop" "(" dropObject=[WorldObject:UNIQUE] ")";




Mission:
    "Mission" "{"
        ID
        Description? 
        EnvironmentProperty
        RobotsProperty
        StartPositions 
        Tasks?
    "}";

Description: 
    "Description" ":" description=STRING;

EnvironmentProperty:
    "Environment" ":" environment = [Environment:UNIQUE];
RobotsProperty:
    "Robots" ":" robots+=[Robot:UNIQUE] (',' robots+=[Robot:UNIQUE])*;
StartPositions:
    "StartPositions" ":" startPositions+=Position (',' startPositions+=Position);
Tasks:
    "Tasks" "{" tasks += Task* "}";
Task: robot=[Robot:UNIQUE]  action=Action;



// General values and properties
ID:
    "ID" ":" id=UNIQUE;

Angle:
    "Angle" ":" angle=Expression;
Length:
    "Length" ":" length=Expression;
Weight:
    "Weight" ":" weight=Expression;
SizeProperty:
    "Size" ":" Size;
Size: 
    "(" length=Expression "," width=Expression "," height=Expression ")";
PositionProperty:
    "Position" ":" Position;
Position: 
    "(" x=Expression "," y=Expression "," z=Expression ")";
VectorProperty:
    "Vector" ":" Vector;
Vector: 
    "(" x=Expression "," y=Expression "," z=Expression ")";


// Number stuff
Expression: Addition;

Addition  infers Expression: 
    Multiplication     ({infer BinExpression.left=current} operator=('+'|'-') right=Multiplication)*;

Multiplication infers Expression: 
    PrimaryExpression ({infer BinExpression.left=current} operator=('*'|'/') right=PrimaryExpression)*;

PrimaryExpression: Literal | Group | NegativeExpression;

Literal:                
    value=NUMBER;
Group:                  
    "(" group=Expression ")";
NegativeExpression:     
    "-" negativeExpression=Expression;



// Terminals
terminal UNIQUE returns string:         
    /[_a-zA-Z][\w_]*/;
// "text"
terminal STRING returns string: 
    /"[^"]*"/;
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
