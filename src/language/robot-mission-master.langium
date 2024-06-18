grammar RobotMissionMaster

entry Model:
    (instances += Instance)*;

Instance:
    mission = Mission |
    environment = Environment |
    robot = Robot |
    worldObject = WorldObject |
    obstacle = Obstacle;

// Environment
Environment:
    "Environment" "{"
        id = ID &
        sizeProperty = SizeProperty &
        objects = Objects &
        obstacles = Obstacles
    "}";

Objects:
    "Objects" "{"
        objects += WorldObject*
    "}";

WorldObject:
    "WorldObject" "{"
        id = ID &
        positionProperty = PositionProperty &
        sizeProperty = SizeProperty &
        weight = Weight
    "}";

Obstacles:
    "Obstacles" "{"
        obstacles += Obstacle*
    "}";

Obstacle:
    "Obstacle" "{"
        id = ID &
        positionProperty = PositionProperty &
        obstacleType = ObstacleType &
        sizeProperty = SizeProperty
    "}";

ObstacleType:
    "ObstacleType" ":" obstacleType = ("Land" | "Water" | "Air" | "Weather");

// Robot
Robot:
    "Robot" "{"
        id = ID &
        robotType = RobotType &
        battery = Battery &
        capacity = Capacity
    "}";

Battery:
    "Battery" ":" battery = Expression;

RobotType:
    "RobotType" ":" robotType = ("Land" | "SurfaceWater" | "Underwater" | "Air");

Capacity:
    "Capacity" ":" capacity = Expression;

// Actions
Action:
    Move | Turn | MoveTo | Wait | Pickup | Drop | ReturnToStart;

Move:
    "Move" "(" direction = VectorProperty "," length = Length ")";

MoveTo:
    "Position" "(" position = Position ")";

Turn:
    "Turn" "(" (angle = Angle | direction = Vector) ")";

Wait:
    "Wait" "(" time = Expression ")";

Pickup:
    "Pickup" "(" pickupObject = [WorldObject:UNIQUE] ")";

Drop:
    "Drop" "(" dropObject = [WorldObject:UNIQUE] ")";

ReturnToStart returns string:
    "ReturnToStart";

// Mission
Mission:
    "Mission" "{"
        id = ID &
        description = Description? 
        environmentProperty = EnvironmentProperty &
        robotsProperty = RobotsProperty &
        startPositions = StartPositions &
        tasks = Tasks?
    "}";

Description:
    "Description" ":" description = STRING;

EnvironmentProperty:
    "Environment" ":" environment = [Environment:UNIQUE];

RobotsProperty:
    "Robots" ":" robots += [Robot:UNIQUE] ("," robots += [Robot:UNIQUE])*;

StartPositions:
    "StartPositions" ":" startPositions += Position ("," startPositions += Position)*;

Tasks:
    "Tasks" "{" tasks += Task* "}";

Task:
    robot = [Robot:UNIQUE] action = Action;

// General values and properties
ID:
    "ID" ":" id = UNIQUE;

Angle:
    "Angle" ":" angle = Expression;

Length:
    "Length" ":" length = Expression;

Weight:
    "Weight" ":" weight = Expression;

SizeProperty:
    "Size" ":" size = Size;

Size:
    "(" length = Expression "," width = Expression "," height = Expression ")";

PositionProperty:
    "Position" ":" position = Position;

Position:
    "(" x = Expression "," y = Expression "," z = Expression ")";

VectorProperty:
    "Vector" ":" vector = Vector;

Vector:
    "(" x = Expression "," y = Expression "," z = Expression ")";

// Number stuff
Expression: Addition;

Addition infers Expression:
    Multiplication ({infer BinExpression.left = current} operator = ('+' | '-') right = Multiplication)*;

Multiplication infers Expression:
    PrimaryExpression ({infer BinExpression.left = current} operator = ('*' | '/') right = PrimaryExpression)*;

PrimaryExpression:
    Literal | Group | NegativeExpression;

Literal:
    value = NUMBER;

Group:
    "(" group = Expression ")";

NegativeExpression:
    "-" negativeExpression = Expression;

// Terminals
terminal UNIQUE returns string:
    /[_a-zA-Z][\w_]*/;

terminal STRING returns string:
    /"[^"]*"/;

terminal NUMBER returns number:
    /(?:(?:-?[0-9]+)?\.[0-9]+)|-?[0-9]+/;

// Ignore whitespaces
hidden terminal WS:
    /\s+/;

// Comments
hidden terminal ML_COMMENT:
    /\/\*[\s\S]*?\*\//;

hidden terminal SL_COMMENT:
    /\/\/[^\n\r]*/;
