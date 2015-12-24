TEMPLATE += app

CONFIG += console
QT += widgets quick

QMAKE_CXXFLAGS += -Wall -g

RESOURCES += ./qrc/resources.qrc

SOURCES += ./cpp/main.cpp \
	./cpp/context.cpp \
	./cpp/highlighter.cpp \
	./cpp/shaderitem.cpp \

HEADERS += \
	./cpp/context.h \
	./cpp/highlighter.h \
	./cpp/shaderitem.h \

DEPENDPATH += ./cpp ./qml ./js

QMAKE_STRIP =
QMAKE_LFLAGS_RELEASE =
