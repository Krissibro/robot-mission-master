import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { RobotMissionMasterAstType, Person } from './generated/ast.js';
import type { RobotMissionMasterServices } from './robot-mission-master-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: RobotMissionMasterServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.RobotMissionMasterValidator;
    const checks: ValidationChecks<RobotMissionMasterAstType> = {
        Person: validator.checkPersonStartsWithCapital
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class RobotMissionMasterValidator {

    checkPersonStartsWithCapital(person: Person, accept: ValidationAcceptor): void {
        if (person.name) {
            const firstChar = person.name.substring(0, 1);
            if (firstChar.toUpperCase() !== firstChar) {
                accept('warning', 'Person name should start with a capital.', { node: person, property: 'name' });
            }
        }
    }

}
