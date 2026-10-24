import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Packages/Core/constants/app_roles.dart';
import 'package:na3eeman/core/auth/role_permission_manager.dart';

// Characterization tests for lib/core/auth/role_permission_manager.dart.
// RolePermissionManager's methods take a non-nullable UserRole, so there is
// no null-role path to exercise; unknown raw strings are handled by
// UserRoleExtension.fromString, which is characterized here too.
void main() {
  // The five owner-equivalent roles treated identically by most gates.
  const ownerEquivalentRoles = {
    UserRole.owner,
    UserRole.manager,
    UserRole.ownerExpert,
    UserRole.cofounder,
    UserRole.cofounderExpert,
  };

  // Owner-equivalent + receptionist + admin: the "management" cluster.
  const managementRoles = {
    UserRole.owner,
    UserRole.manager,
    UserRole.ownerExpert,
    UserRole.cofounder,
    UserRole.cofounderExpert,
    UserRole.receptionist,
    UserRole.admin,
  };

  // Full expected grant sets per gate, built from the implementation.
  const expectedMatrix = <String, Set<UserRole>>{
    'canAccessSalonManagement': {
      UserRole.owner,
      UserRole.manager,
      UserRole.ownerExpert,
      UserRole.cofounder,
      UserRole.cofounderExpert,
      UserRole.admin,
    },
    'canEditSalonInfo': {
      UserRole.owner,
      UserRole.manager,
      UserRole.ownerExpert,
      UserRole.cofounder,
      UserRole.cofounderExpert,
      UserRole.admin,
    },
    'canDeleteSalon': {UserRole.admin},
    'canManageInventory': {
      UserRole.owner,
      UserRole.manager,
      UserRole.ownerExpert,
      UserRole.cofounder,
      UserRole.cofounderExpert,
      UserRole.receptionist,
      UserRole.admin,
    },
    'canManageFinancials': {
      UserRole.owner,
      UserRole.manager,
      UserRole.ownerExpert,
      UserRole.cofounder,
      UserRole.cofounderExpert,
      UserRole.admin,
    },
    'canManageSubscriptions': {
      UserRole.owner,
      UserRole.manager,
      UserRole.ownerExpert,
      UserRole.cofounder,
      UserRole.cofounderExpert,
      UserRole.receptionist,
      UserRole.admin,
    },
    'canManageOffersAndAds': {
      UserRole.owner,
      UserRole.manager,
      UserRole.ownerExpert,
      UserRole.cofounder,
      UserRole.cofounderExpert,
      UserRole.receptionist,
      UserRole.admin,
    },
    'canViewFeedback': {
      UserRole.owner,
      UserRole.manager,
      UserRole.ownerExpert,
      UserRole.cofounder,
      UserRole.cofounderExpert,
      UserRole.receptionist,
      UserRole.admin,
    },
    'canManageAppointments': {
      UserRole.owner,
      UserRole.manager,
      UserRole.ownerExpert,
      UserRole.cofounder,
      UserRole.cofounderExpert,
      UserRole.receptionist,
      UserRole.admin,
    },
    'canBookAppointments': {UserRole.customer},
    'canViewAllExpertSchedules': {
      UserRole.owner,
      UserRole.manager,
      UserRole.ownerExpert,
      UserRole.cofounder,
      UserRole.cofounderExpert,
      UserRole.receptionist,
      UserRole.admin,
    },
    'canViewAdminDashboard': {UserRole.admin},
  };

  bool gate(String name, UserRole role) {
    switch (name) {
      case 'canAccessSalonManagement':
        return RolePermissionManager.canAccessSalonManagement(role);
      case 'canEditSalonInfo':
        return RolePermissionManager.canEditSalonInfo(role);
      case 'canDeleteSalon':
        return RolePermissionManager.canDeleteSalon(role);
      case 'canManageInventory':
        return RolePermissionManager.canManageInventory(role);
      case 'canManageFinancials':
        return RolePermissionManager.canManageFinancials(role);
      case 'canManageSubscriptions':
        return RolePermissionManager.canManageSubscriptions(role);
      case 'canManageOffersAndAds':
        return RolePermissionManager.canManageOffersAndAds(role);
      case 'canViewFeedback':
        return RolePermissionManager.canViewFeedback(role);
      case 'canManageAppointments':
        return RolePermissionManager.canManageAppointments(role);
      case 'canBookAppointments':
        return RolePermissionManager.canBookAppointments(role);
      case 'canViewAllExpertSchedules':
        return RolePermissionManager.canViewAllExpertSchedules(role);
      case 'canViewAdminDashboard':
        return RolePermissionManager.canViewAdminDashboard(role);
      default:
        fail('unknown gate $name');
    }
  }

  group('RolePermissionManager — full role x permission matrix', () {
    test('every gate matches the expected grant set for every role', () {
      expectedMatrix.forEach((gateName, allowed) {
        for (final role in UserRole.values) {
          expect(
            gate(gateName, role),
            allowed.contains(role),
            reason: '$gateName(${role.name})',
          );
        }
      });
    });

    test('customer can only book appointments', () {
      expectedMatrix.forEach((gateName, allowed) {
        expect(
          gate(gateName, UserRole.customer),
          gateName == 'canBookAppointments',
          reason: '$gateName(customer)',
        );
      });
    });

    test('expert and artisan have NO permissions at all', () {
      // Quirk: experts cannot book appointments and have no management gates.
      for (final role in {UserRole.expert, UserRole.artisan}) {
        expectedMatrix.forEach((gateName, _) {
          expect(gate(gateName, role), isFalse, reason: '$gateName($role)');
        });
      }
    });

    test('intern has NO permissions at all', () {
      expectedMatrix.forEach((gateName, _) {
        expect(
          gate(gateName, UserRole.intern),
          isFalse,
          reason: '$gateName(intern)',
        );
      });
    });

    test('receptionist is management except salon info/financials/delete', () {
      for (final gateName in expectedMatrix.keys) {
        final allowed =
            managementRoles.contains(UserRole.receptionist) &&
            !{
              'canAccessSalonManagement',
              'canEditSalonInfo',
              'canDeleteSalon',
              'canManageFinancials',
              'canViewAdminDashboard',
              'canBookAppointments',
            }.contains(gateName);
        expect(
          gate(gateName, UserRole.receptionist),
          allowed,
          reason: '$gateName(receptionist)',
        );
      }
    });

    test('all five owner-equivalent roles behave identically', () {
      for (final role in ownerEquivalentRoles) {
        expectedMatrix.forEach((gateName, allowed) {
          expect(
            gate(gateName, role),
            gate(gateName, UserRole.owner),
            reason: '$gateName(${role.name}) should match owner',
          );
        });
      }
    });
  });

  group('RolePermissionManager.isStaff', () {
    test('isStaff is true for every role except customer', () {
      for (final role in UserRole.values) {
        expect(
          RolePermissionManager.isStaff(role),
          role != UserRole.customer,
          reason: 'isStaff(${role.name})',
        );
      }
    });

    test('quirk: admin and intern count as staff', () {
      expect(RolePermissionManager.isStaff(UserRole.admin), isTrue);
      expect(RolePermissionManager.isStaff(UserRole.intern), isTrue);
    });
  });

  group('RolePermissionManager.getDefaultRoute', () {
    test('management roles route to /management_dashboard', () {
      for (final role in {
        UserRole.owner,
        UserRole.cofounder,
        UserRole.manager,
        UserRole.receptionist,
      }) {
        expect(
          RolePermissionManager.getDefaultRoute(role),
          '/management_dashboard',
          reason: 'route(${role.name})',
        );
      }
    });

    test('practitioner roles route to /expert_dashboard', () {
      for (final role in {
        UserRole.ownerExpert,
        UserRole.cofounderExpert,
        UserRole.expert,
        UserRole.artisan,
      }) {
        expect(
          RolePermissionManager.getDefaultRoute(role),
          '/expert_dashboard',
          reason: 'route(${role.name})',
        );
      }
    });

    test('admin routes to /admin', () {
      expect(RolePermissionManager.getDefaultRoute(UserRole.admin), '/admin');
    });

    test('intern routes to /intern_dashboard', () {
      expect(
        RolePermissionManager.getDefaultRoute(UserRole.intern),
        '/intern_dashboard',
      );
    });

    test('customer routes to /customer_home', () {
      expect(
        RolePermissionManager.getDefaultRoute(UserRole.customer),
        '/customer_home',
      );
    });

    test('every role resolves to exactly one known route', () {
      const knownRoutes = {
        '/management_dashboard',
        '/expert_dashboard',
        '/admin',
        '/intern_dashboard',
        '/customer_home',
      };
      for (final role in UserRole.values) {
        expect(
          knownRoutes,
          contains(RolePermissionManager.getDefaultRoute(role)),
          reason: 'route(${role.name})',
        );
      }
    });
  });

  group('UserRole helpers used by RolePermissionManager', () {
    test('isOwnerEquivalent contains exactly the five management roles', () {
      for (final role in UserRole.values) {
        expect(
          role.isOwnerEquivalent,
          ownerEquivalentRoles.contains(role),
          reason: '${role.name}.isOwnerEquivalent',
        );
      }
    });

    test('UserRole.isStaff extension is true for all but customer', () {
      for (final role in UserRole.values) {
        expect(
          role.isStaff,
          role != UserRole.customer,
          reason: '${role.name}.isStaff',
        );
      }
    });

    test('displayName and value mappings', () {
      expect(UserRole.customer.displayName, 'Customer');
      expect(UserRole.expert.displayName, 'Expert');
      expect(UserRole.intern.displayName, 'Intern');
      expect(UserRole.receptionist.displayName, 'Receptionist');
      expect(UserRole.owner.displayName, 'Owner');
      expect(UserRole.manager.displayName, 'Manager');
      expect(UserRole.ownerExpert.displayName, 'Owner Expert');
      expect(UserRole.cofounder.displayName, 'Co-Founder');
      expect(UserRole.cofounderExpert.displayName, 'Co-Founder Expert');
      expect(UserRole.artisan.displayName, 'Artisan');
      expect(UserRole.admin.displayName, 'Admin');

      // Quirk: value is name.toUpperCase() with no word separator, so
      // camelCase roles do NOT round-trip through fromString's snake_case
      // aliases (fromString('COFOUNDEREXPERT') would fall back to customer).
      expect(UserRole.cofounderExpert.value, 'COFOUNDEREXPERT');
      expect(UserRole.ownerExpert.value, 'OWNEREXPERT');
      expect(UserRole.admin.value, 'ADMIN');
    });
  });

  group('UserRoleExtension.fromString — edge cases', () {
    test('unknown strings fall back to customer', () {
      expect(UserRoleExtension.fromString('SUPERUSER'), UserRole.customer);
      expect(UserRoleExtension.fromString(''), UserRole.customer);
      expect(UserRoleExtension.fromString('not-a-role'), UserRole.customer);
    });

    test('parsing is case-insensitive', () {
      expect(UserRoleExtension.fromString('owner'), UserRole.owner);
      expect(UserRoleExtension.fromString('Admin'), UserRole.admin);
    });

    test('documented legacy aliases resolve', () {
      expect(UserRoleExtension.fromString('EMPLOYEE'), UserRole.expert);
      expect(UserRoleExtension.fromString('HELPER'), UserRole.intern);
      expect(UserRoleExtension.fromString('OWNER_OWNER'), UserRole.owner);
      expect(
        UserRoleExtension.fromString('OWNER_EXPERT'),
        UserRole.ownerExpert,
      );
      expect(
        UserRoleExtension.fromString('OWNER_EMPLOYEE'),
        UserRole.ownerExpert,
      );
      expect(UserRoleExtension.fromString('COFOUNDER'), UserRole.cofounder);
      expect(UserRoleExtension.fromString('CO_FOUNDER'), UserRole.cofounder);
      expect(
        UserRoleExtension.fromString('COFOUNDER_EXPERT'),
        UserRole.cofounderExpert,
      );
      expect(UserRoleExtension.fromString('SUPERADMIN'), UserRole.admin);
      expect(UserRoleExtension.fromString('SUPER_ADMIN'), UserRole.admin);
    });
  });

  group('UserRolePermissions.can — granular permission map', () {
    test('admin holds every AppPermission', () {
      for (final permission in AppPermission.values) {
        expect(
          UserRole.admin.can(permission),
          isTrue,
          reason: 'admin.can($permission)',
        );
      }
    });

    test('customer holds only booking permissions', () {
      const expected = {
        AppPermission.viewBookings,
        AppPermission.createBooking,
        AppPermission.rescheduleBooking,
      };
      for (final permission in AppPermission.values) {
        expect(
          UserRole.customer.can(permission),
          expected.contains(permission),
          reason: 'customer.can($permission)',
        );
      }
    });

    test('owner permission set matches the declared map exactly', () {
      const expected = {
        AppPermission.viewBookings,
        AppPermission.createBooking,
        AppPermission.cancelAnyBooking,
        AppPermission.rescheduleBooking,
        AppPermission.viewCustomerList,
        AppPermission.editCustomerProfile,
        AppPermission.viewStaffList,
        AppPermission.manageStaff,
        AppPermission.setStaffRoles,
        AppPermission.viewSalonRevenue,
        AppPermission.viewPayoutRequests,
        AppPermission.viewReports,
        AppPermission.downloadReports,
        AppPermission.editSalonProfile,
        AppPermission.manageSessions,
        AppPermission.manageServices,
        AppPermission.viewAnalytics,
        AppPermission.viewPeakHours,
      };
      for (final permission in AppPermission.values) {
        expect(
          UserRole.owner.can(permission),
          expected.contains(permission),
          reason: 'owner.can($permission)',
        );
      }
    });

    test('cofounder permission set matches the declared map exactly', () {
      // Comment in source says "identical to Owner" but cofounder has four
      // extra permissions: banCustomer, approvePayouts, viewSubscriptionRevenue
      // are extras beyond owner (banCustomer/approvePayouts/
      // viewSubscriptionRevenue). Characterize the actual set.
      const expected = {
        AppPermission.viewBookings,
        AppPermission.createBooking,
        AppPermission.cancelAnyBooking,
        AppPermission.rescheduleBooking,
        AppPermission.viewCustomerList,
        AppPermission.editCustomerProfile,
        AppPermission.banCustomer,
        AppPermission.viewStaffList,
        AppPermission.manageStaff,
        AppPermission.setStaffRoles,
        AppPermission.viewSalonRevenue,
        AppPermission.viewPayoutRequests,
        AppPermission.approvePayouts,
        AppPermission.viewSubscriptionRevenue,
        AppPermission.viewReports,
        AppPermission.downloadReports,
        AppPermission.editSalonProfile,
        AppPermission.manageSessions,
        AppPermission.manageServices,
        AppPermission.viewAnalytics,
        AppPermission.viewPeakHours,
      };
      for (final permission in AppPermission.values) {
        expect(
          UserRole.cofounder.can(permission),
          expected.contains(permission),
          reason: 'cofounder.can($permission)',
        );
      }
    });

    test('quirk: cofounderExpert lacks cofounder-only permissions', () {
      // cofounder has banCustomer, approvePayouts, viewSubscriptionRevenue;
      // cofounderExpert does not, despite both being owner-equivalent.
      expect(UserRole.cofounder.can(AppPermission.banCustomer), isTrue);
      expect(UserRole.cofounderExpert.can(AppPermission.banCustomer), isFalse);
      expect(UserRole.cofounder.can(AppPermission.approvePayouts), isTrue);
      expect(
        UserRole.cofounderExpert.can(AppPermission.approvePayouts),
        isFalse,
      );
      expect(
        UserRole.cofounder.can(AppPermission.viewSubscriptionRevenue),
        isTrue,
      );
      expect(
        UserRole.cofounderExpert.can(AppPermission.viewSubscriptionRevenue),
        isFalse,
      );
    });

    test('expert and artisan share the same permission set', () {
      const expected = {
        AppPermission.viewBookings,
        AppPermission.viewCustomerList,
        AppPermission.viewReports,
        AppPermission.manageServices,
        AppPermission.manageSessions,
      };
      for (final role in {UserRole.expert, UserRole.artisan}) {
        for (final permission in AppPermission.values) {
          expect(
            role.can(permission),
            expected.contains(permission),
            reason: '${role.name}.can($permission)',
          );
        }
      }
    });

    test('intern holds only viewBookings and viewCustomerList', () {
      const expected = {
        AppPermission.viewBookings,
        AppPermission.viewCustomerList,
      };
      for (final permission in AppPermission.values) {
        expect(
          UserRole.intern.can(permission),
          expected.contains(permission),
          reason: 'intern.can($permission)',
        );
      }
    });

    test('receptionist permission set matches the declared map exactly', () {
      const expected = {
        AppPermission.viewBookings,
        AppPermission.createBooking,
        AppPermission.cancelAnyBooking,
        AppPermission.rescheduleBooking,
        AppPermission.viewCustomerList,
      };
      for (final permission in AppPermission.values) {
        expect(
          UserRole.receptionist.can(permission),
          expected.contains(permission),
          reason: 'receptionist.can($permission)',
        );
      }
    });
  });
}
