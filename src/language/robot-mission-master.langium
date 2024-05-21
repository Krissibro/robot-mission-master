grammar RobotMissionMaster


entry Model: 
    (definitions += Definition)*;    


// Element syntax stuff
Definition:
    DefinitionBlock | 
    Mission | 
    Environment | 
    Robot | 
    Tasks | 
    Objects |
    WorldObject | 
    Obstacles |
    Obstacle;

DefinitionBlock:    
    name=ID '{' 
        (properties+=Property)* 
    '}';

Property:
    PropertyBlock | 
    Size;

PropertyBlock:
    name=ID ":" value=Property;


ActionBlock:
    robot=[Robot:ID] name=ID '(' (action+=Action (',' action+=Action)*)? ')';  


// Environment 
Environment: 
    name=ID &
    Size=Size &
    objects=Objects &
    obstacles=Obstacles;

WorldObject: 
    name=ID &
    position=Position &  
    size=Size &
    weight=NUMBER;

Obstacle:
    name=ID &
    position=Position &
    ObstacleType &
    Size;

Objects:
    objects+=WorldObject*;

Obstacles:
    obstacles+=Obstacle*;

terminal ObstacleType:
    "Land" | "Water" | "Air" | "Weather";



// Robot
Robot: 
    name=ID &
    robotType=RobotType &
    battery=Expression 
    possibleActions = Action*;

// PossibleActions:    
//     actions+=Action*;
// StartPosition:    
//     startPosition=Position*;
// Battery:    
//     battery=Expression;
terminal RobotType: 
    "Land" | "SurfaceWater" | "Underwater" | "Air";


Action: 
    ActionBlock | Move | Turn | MoveTo | Wait | Pickup | Drop | ReturnToStart | CustomAction;



Move: 
     direction=Vector length=Expression;
MoveTo: 
    position=Position;
Turn: 
    (angle=Expression | direction=Vector);
Wait: 
    time=Expression;
Pickup: 
    pickup=WorldObject;
Drop: 
    drop=WorldObject;
CustomAction: 
    description=STRING;
ReturnToStart:
    position=[Mission:ID];



Mission:
    name=ID
    Description? 
    environment = [Environment:ID] 
    robots += [Robot:ID]+
    startPositions += Position* 
    Tasks?;

Description: 
    description=STRING?;
Tasks:
    tasks += Task*;

Task: Robot  Action;


// MultipleRobotActions: 
//     multipleRobotActions+=Action*;
// Time: 
//     time=Expression*;





// Tuples with numerical info
Size: 
    "(" length=Expression "," width=Expression "," height=Expression ")";
// Weight: 
//     weight=Expression;
Position: 
    "(" x=Expression "," y=Expression "," z=Expression ")";
Vector: 
    "(" x=Expression "," y=Expression "," z=Expression ")";






// Number stuff
Expression: Addition;

Addition  infers Expression: 
    Multiplication     ({infer BinExpression.left=current} op=('+'|'-') right=Multiplication)*;

Multiplication infers Expression: 
    PrimaryExpression ({infer BinExpression.left=current} op=('*'|'/') right=PrimaryExpression)*;

PrimaryExpression: Literal | Reference | Group | NegativeExpression;

Literal:                
    value=NUMBER;
Reference:              
    value=[Property:ID];
Group:                  
    "(" group=Expression ")";
NegativeExpression:     
    "-" negativeExpression=Expression;


// Terminals
terminal ID returns string:         
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
