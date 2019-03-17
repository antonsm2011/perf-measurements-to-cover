#Использовать "."
#Использовать cli
#Использовать logos

Перем _ПутьКФайлуПокрытия;
Перем _ФайлыЗамеров;
Перем _ПутьККаталогуИсходников;
Перем _ГенераторПутей;
Перем _Лог;

Функция ИмяЛога() Экспорт
	Возврат "perf-measurements-to-cover";
КонецФункции

Процедура ВыполнитьПриложение()
	
	Приложение = Новый КонсольноеПриложение( 
		"perf-measurements-to-cover",
		"Конвертация замеров производительности из 1С в файл покрытия");
	Приложение.Версия("v version", "0.0.1");
	
	Приложение.ДобавитьКоманду("c convert", "Выполнить конвертацию", Новый Конвертация);

	Приложение.Запустить(АргументыКоманднойСтроки);
	
КонецПроцедуры

Попытка
	
	ВыполнитьПриложение();
	
Исключение
	
	Сообщить(ОписаниеОшибки());
	
КонецПопытки;