import type { ValidationAcceptor, ValidationChecks } from 'langium';
import { isInstance, Model, RobotMissionMasterAstType} from './generated/ast.js';
import type { RobotMissionMasterServices } from './robot-mission-master-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: RobotMissionMasterServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.RobotMissionMasterValidator;

    const checks: ValidationChecks<RobotMissionMasterAstType> = {
        Model: validator.checkUniqueInstanceIDs
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class RobotMissionMasterValidator {
    
    checkUniqueInstanceIDs(model: Model, accept: ValidationAcceptor): void {
        const uniqueIDs = new Set<string>();

        model.instances.forEach(instance => {
            if (isInstance(instance) && 'id' in instance) {
                const id = instance.id;
                if (uniqueIDs.has(id)) {
                    accept('error', `Instance has non-unique ID '${id}'.`, { node: instance, property: 'id' });
                } else {
                    uniqueIDs.add(id);
                }
            }
        });
    
    }

    // TODO: Check if WorldObjects or Obstacles overlap
}
