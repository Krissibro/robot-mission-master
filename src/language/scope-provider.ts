import { ReferenceInfo, Scope, ScopeProvider, AstUtils, LangiumCoreServices, AstNodeDescriptionProvider, MapScope, EMPTY_SCOPE } from 'langium';
import { Environment, Mission, Task, Robot, WorldObject, Obstacle, Model } from './generated/ast.js';
import { isEnvironment, isMission, isRobot, isWorldObject, isObstacle, isTask, isModel } from './generated/ast.js';

export class RobotMissionMasterScopeProvider implements ScopeProvider {

    private astNodeDescriptionProvider: AstNodeDescriptionProvider;

    constructor(services: LangiumCoreServices) {
        this.astNodeDescriptionProvider = services.workspace.AstNodeDescriptionProvider;
    }

    getScope(context: ReferenceInfo): Scope {
        const container = context.container;

        if (isMission(container) && context.property === 'environment') {
            return this.getScopeForEnvironment(container);
        }

        if ((isMission(container) || isTask(container)) && context.property === 'robots') {
            return this.getScopeForRobots(container);
        }

        if (isTask(container) && (context.property === 'pickupObject' || context.property === 'dropObject')) {
            return this.getScopeForWorldObjects(container);
        }

        if (isTask(container) && context.property === 'obstacle') {
            return this.getScopeForObstacles(container);
        }

        return EMPTY_SCOPE;
    }

    private getScopeForEnvironment(mission: Mission): Scope {
        const model = AstUtils.getContainerOfType(mission, isModel) as Model;
        if (!model) {
            return EMPTY_SCOPE;
        }
        const environments = model.instances.filter(isEnvironment);
        const descriptions = environments.map(environment => this.astNodeDescriptionProvider.createDescription(environment, environment.id));
        return new MapScope(descriptions);
    }

    private getScopeForRobots(container: Mission | Task): Scope {
        const model = AstUtils.getContainerOfType(container, isModel) as Model;
        if (!model) {
            return EMPTY_SCOPE;
        }
        const robots = model.instances.filter(isRobot);
        const descriptions = robots.map(robot => this.astNodeDescriptionProvider.createDescription(robot, robot.id));
        return new MapScope(descriptions);
    }

    private getScopeForWorldObjects(task: Task): Scope {
        const mission = AstUtils.getContainerOfType(task, isMission) as Mission;
        if (!mission) {
            return EMPTY_SCOPE;
        }
        const environment = mission.environment.ref;
        if (isEnvironment(environment)) {
            const worldObjects = environment.objects.objects;
            const descriptions = worldObjects.map(object => this.astNodeDescriptionProvider.createDescription(object, object.id));
            return new MapScope(descriptions);
        }
        return EMPTY_SCOPE;
    }

    private getScopeForObstacles(task: Task): Scope {
        const mission = AstUtils.getContainerOfType(task, isMission) as Mission;
        if (!mission) {
            return EMPTY_SCOPE;
        }
        const environment = mission.environment.ref;
        if (isEnvironment(environment)) {
            const obstacles = environment.obstacles.obstacles;
            const descriptions = obstacles.map(obstacle => this.astNodeDescriptionProvider.createDescription(obstacle, obstacle.id));
            return new MapScope(descriptions);
        }
        return EMPTY_SCOPE;
    }
}
