#pragma once
#include <qcontainerfwd.h>
#include <qdatetime.h>
#include <qobject.h>
struct Message {
  QString id;
  QString tempId;
  QString sender;
  QString text;
  QString status;
  QString created_at;
  QString media;
  bool forwarded;
  QString forwarded_by;
};