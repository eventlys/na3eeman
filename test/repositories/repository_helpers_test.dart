import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Services/enums/points_types.dart';
import 'package:na3eeman/Services/enums/report_enums.dart';
import 'package:na3eeman/Services/repositories/loyalty_repository.dart';
import 'package:na3eeman/Services/repositories/report_repository.dart';

// Characterization tests for the pure helpers extracted verbatim from the
// former god service `BusinessService` into the focused repositories.
void main() {
  group('LoyaltyRepository', () {
    final repo = LoyaltyRepository();

    test('pointsValues matches the legacy BusinessService table', () {
      expect(
        LoyaltyRepository.pointsValues[PointsType.appointmentComplete],
        50,
      );
      expect(LoyaltyRepository.pointsValues[PointsType.reviewWrite], 25);
      expect(LoyaltyRepository.pointsValues[PointsType.referral], 100);
      expect(LoyaltyRepository.pointsValues[PointsType.rewardRedeem], 0);
      expect(LoyaltyRepository.pointsValues[PointsType.signup], 100);
      expect(LoyaltyRepository.pointsValues[PointsType.milestoneReached], 200);
      expect(LoyaltyRepository.pointsValues[PointsType.other], 10);
    });

    test('getPointsForAction returns the configured value per action', () {
      for (final action in PointsType.values) {
        expect(
          repo.getPointsForAction(action),
          LoyaltyRepository.pointsValues[action] ?? 0,
        );
      }
    });

    test('getDefaultDescription mirrors the legacy switch', () {
      expect(
        repo.getDefaultDescription(PointsType.appointmentComplete),
        'Appointment completed',
      );
      expect(
        repo.getDefaultDescription(PointsType.reviewWrite),
        'Review written',
      );
      expect(
        repo.getDefaultDescription(PointsType.referral),
        'Customer referred',
      );
      expect(
        repo.getDefaultDescription(PointsType.rewardRedeem),
        'Reward redeemed',
      );
      expect(
        repo.getDefaultDescription(PointsType.signup),
        'Welcome bonus awarded',
      );
      expect(
        repo.getDefaultDescription(PointsType.milestoneReached),
        'Loyalty milestone reached',
      );
      expect(repo.getDefaultDescription(PointsType.other), 'Points awarded');
    });

    test(
      'awardPoints builds a local PointsModel with default description',
      () async {
        final model = await repo.awardPoints(
          userId: 7,
          action: PointsType.referral,
        );

        expect(model.userId, 7);
        expect(model.points, 100);
        expect(model.type, PointsType.referral);
        expect(model.description, 'Customer referred');
      },
    );

    test('awardReviewPoints uses reviewWrite metadata', () async {
      final model = await repo.awardReviewPoints(3, 55);

      expect(model.userId, 3);
      expect(model.points, 25);
      expect(model.type, PointsType.reviewWrite);
      expect(model.description, 'Points for writing a review');
      expect(model.metadata, {'review_id': 55});
    });
  });

  group('ReportRepository.getTimeDisplayName', () {
    final repo = ReportRepository();

    test('maps each ReportTime to its display name', () {
      expect(repo.getTimeDisplayName(ReportTime.daily), 'Daily');
      expect(repo.getTimeDisplayName(ReportTime.weekly), 'Weekly');
      expect(repo.getTimeDisplayName(ReportTime.monthly), 'Monthly');
      expect(repo.getTimeDisplayName(ReportTime.annually), 'Annually');
    });
  });

  group('ReportRequest.toJson', () {
    test('serializes fields with enum names and null report type', () {
      final request = ReportRequest(
        time: ReportTime.weekly,
        startDate: DateTime.utc(2024, 1, 1),
        endDate: DateTime.utc(2024, 1, 7),
        fileName: 'weekly_report',
      );

      final json = request.toJson();

      expect(json['time'], 'weekly');
      expect(json['start_date'], '2024-01-01T00:00:00.000Z');
      expect(json['end_date'], '2024-01-07T00:00:00.000Z');
      expect(json['branch_id'], isNull);
      expect(json['format'], 'pdf');
      expect(json['file_name'], 'weekly_report');
      expect(json['report_type'], isNull);
    });

    test('includes branch and report type when provided', () {
      final request = ReportRequest(
        time: ReportTime.daily,
        startDate: DateTime.utc(2024, 2, 1),
        endDate: DateTime.utc(2024, 2, 1),
        branchId: 'b1',
        format: ReportFormat.csv,
        fileName: 'f',
        reportType: ReportType.staff,
      );

      final json = request.toJson();

      expect(json['branch_id'], 'b1');
      expect(json['format'], 'csv');
      expect(json['report_type'], 'staff');
    });
  });

  group('StaffReportRequest.toJson', () {
    test('serializes fields with enum names', () {
      final request = StaffReportRequest(
        time: ReportTime.monthly,
        startDate: DateTime.utc(2024, 3, 1),
        endDate: DateTime.utc(2024, 3, 31),
        staffId: 's9',
        fileName: 'staff_report',
        reportType: StaffReportType.payroll,
      );

      final json = request.toJson();

      expect(json['time'], 'monthly');
      expect(json['staff_id'], 's9');
      expect(json['branch_id'], isNull);
      expect(json['file_name'], 'staff_report');
      expect(json['report_type'], 'payroll');
    });
  });

  group('ReportData.fromJson', () {
    test('parses a full payload', () {
      final data = ReportData.fromJson({
        'id': 42,
        'time': 'monthly',
        'generated_at': '2024-05-01T10:00:00.000',
        'data': {'count': 3},
        'download_url': 'https://example.com/r.pdf',
        'file_name': 'r.pdf',
      });

      expect(data.id, '42');
      expect(data.time, ReportTime.monthly);
      expect(data.generatedAt, DateTime.parse('2024-05-01T10:00:00.000'));
      expect(data.data, {'count': 3});
      expect(data.downloadUrl, 'https://example.com/r.pdf');
      expect(data.fileName, 'r.pdf');
    });

    test('falls back to monthly and empty id/data on missing fields', () {
      final data = ReportData.fromJson({
        'id': null,
        'time': 'unknown_value',
        'generated_at': '2024-05-01T10:00:00.000',
        'download_url': 'u',
        'file_name': 'f',
      });

      expect(data.id, '');
      expect(data.time, ReportTime.monthly);
      expect(data.data, isEmpty);
    });
  });
}
