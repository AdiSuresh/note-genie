import 'package:note_maker/data/dao_base/dao_base.dart';
import 'package:note_maker/models/note_link/model.dart';

class NoteLinkDao extends DaoBase<NoteLink> {
  static const storeName = 'note_links';

  NoteLinkDao()
      : super(
          storeName,
        );
}
