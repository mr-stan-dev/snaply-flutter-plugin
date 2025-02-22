import 'package:snaply/src/archive/archive_creator.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/mappers/file_to_archive_entry_mapper.dart';
import 'package:snaply/src/mappers/file_to_path_mapper.dart';
import 'package:snaply/src/media_manager/media_files_manager.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';
import 'package:snaply/src/repository/extra_files_repository.dart';
import 'package:snaply/src/ui/viewmodel/snaply_view_model.dart';
import 'package:snaply/src/usecase/share_files_usecase.dart';

class SnaplyViewModelCreator {
  static SnaplyViewModel create() {
    final platformInterface = SnaplyPlatformInterface.instance;

    return SnaplyViewModel(
      mediaManager: MediaFilesManager(platformInterface),
      shareReportUsecase: ShareFilesUsecase(
        archiveCreator: ArchiveCreator(),
        platformInterface: platformInterface,
        fileToPathMapper: FileToPathMapper(),
        archiveEntryMapper: FileToArchiveEntryMapper(),
      ),
      extraFilesRepository: ExtraFilesRepository(
        platform: platformInterface,
        logger: SnaplyLogger.instance,
        customAttributesHolder: CustomAttributesHolder.instance,
      ),
      configurationHolder: ConfigurationHolder.instance,
    );
  }
}
