#Использовать logos
#Использовать v8metadata-reader

#Использовать "../internal"

Перем _Лог;

Перем _ГенераторПутей;
Перем _ПолучениеПоддержки;

Перем _ПутьКФайлуПокрытия;
Перем _ФайлыЗамеров;
Перем _ПутьККаталогуИсходников;
Перем _УровеньПоддержки;

#Область ПрограммныйИнтерфейс

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("i in", "" ,"Путь к файлам с замерами.
	|		Если указан каталог, то будут сконвертированы все файлы *.pff. Например ./perf/")
	.ТМассивСтрок()
	.Обязательный(Истина)
	.ВОкружении("PERF_MEASUREMENTS_PATH");
	
	Команда.Опция("o out", "" ,"Путь к файлу-результату. Например ./coverage/genericCoverage.xml")
	.ТСтрока()
	.Обязательный(Истина)
	.ВОкружении("COVERAGE_RESULT");
	
	Команда.Опция("s src", "" ,"Путь к каталогу с исходниками. Например ./src")
	.ТСтрока()
	.Обязательный(Истина)
	.ВОкружении("SRC");
	
	Команда.Опция("r remove_support", "" ,"Удаляет из отчетов файлы на поддержке. Например -r=0
	|		0 - удалить файлы на замке,
	|		1 - удалить файлы на замке и на поддержке
	|		2 - удалить файлы на замке, на поддержке и снятые с поддержки")
	.ТЧисло()
	.ПоУмолчанию(0)
	.ВОкружении("GENERIC_ISSUE_REMOVE_SUPPORT");
	
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	ИнициализацияПараметров(Команда);
	
	массивДанныхОПокрытии = ЗаполнитьДанныеОПокрытии();

	ЗаписатьФайлПокрытия( массивДанныхОПокрытии );
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ИмяЛога() Экспорт
	Возврат "perf-measurements-to-cover";
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ИнициализацияПараметров(Знач Команда)
	
	_Лог = Логирование.ПолучитьЛог(ИмяЛога());
	
	_ПутьКФайлуПокрытия = Команда.ЗначениеОпции("out");
	путиКФайламЗамеров = Команда.ЗначениеОпции("in");
	путьККаталогуИсходников = Команда.ЗначениеОпции("src");
	_УровеньПоддержки = Команда.ЗначениеОпции("remove_support");
	
	файл = Новый Файл( _ПутьКФайлуПокрытия );
	каталогФайлаПокрытия = Новый Файл( файл.Путь );
	
	Если Не каталогФайлаПокрытия.Существует() Тогда
		
		СоздатьКаталог( файл.Путь );
		
	КонецЕсли;
	
	_ФайлыЗамеров = Новый Массив;
	
	Для Каждого цПуть Из путиКФайламЗамеров Цикл
		
		файл = Новый Файл(цПуть);
		
		Если Не файл.Существует() Тогда
			_Лог.Ошибка( "Файл замеров не найден - %1", цПуть );
			Продолжить;
		КонецЕсли;
		
		Если ВРег( файл.Расширение ) = ВРег( ".pff" ) Тогда
			
			_ФайлыЗамеров.Добавить(файл.ПолноеИмя);
			
		ИначеЕсли файл.ЭтоКаталог() Тогда
			
			Для каждого цФайлЗамеров Из НайтиФайлы( файл.ПолноеИмя, "*.pff" ) Цикл
				
				_ФайлыЗамеров.Добавить(цФайлЗамеров.ПолноеИмя);
				
			КонецЦикла;
			
		Иначе
			
			_Лог.Ошибка( "Это не файл замеров - %1", цПуть );
			
		КонецЕсли;
		
	КонецЦикла;
	
	Для каждого цФайлЗамеров Из _ФайлыЗамеров Цикл
		
		_Лог.Информация( "Добавлен к конвертации %1", цФайлЗамеров);
		
	КонецЦикла;
	
	_ГенераторПутей = Новый Путь1СПоМетаданным(путьККаталогуИсходников);
	_ПолучениеПоддержки = Новый Поддержка(путьККаталогуИсходников);
	
КонецПроцедуры

Функция ЗаполнитьДанныеОПокрытии()
	
	покрытыеМодули = Замеры.МодулиСПокрытием(_ФайлыЗамеров, _ГенераторПутей);
	всеФайлыКПокрытию = _ПолучениеПоддержки.ВсеФайлы( _УровеньПоддержки + 1, "+");
	
	_Лог.Информация( "Прочитано %1 покрытых модулей", покрытыеМодули.Количество() );
	_Лог.Информация( "Прочитано %1 модулей к покрытыю", всеФайлыКПокрытию.Количество() );
	
	массивДанныхОПокрытии = Новый Массив;

	Для Каждого цФайл Из всеФайлыКПокрытию Цикл
			
		модульСПокрытием = Новый ДанныеПокрытия( цФайл, покрытыеМодули );
		
		массивДанныхОПокрытии.Добавить(модульСПокрытием);
		
	КонецЦикла;

	Возврат массивДанныхОПокрытии;

КонецФункции

Процедура ЗаписатьФайлПокрытия( Знач пМассивФайловСПокрытием )
	
	Запись = Новый ЗаписьXML();
	Запись.ОткрытьФайл( _ПутьКФайлуПокрытия );
	
	Запись.ЗаписатьОбъявлениеXML();
	Запись.ЗаписатьНачалоЭлемента( "coverage" );
	Запись.ЗаписатьАтрибут( "version", "1" );
		
	Для Каждого цФайл Из пМассивФайловСПокрытием Цикл
			
		Запись.ЗаписатьНачалоЭлемента("file");
		Запись.ЗаписатьАтрибут("path", цФайл.ПутьКФайлу());
		
		Для Каждого цСтрока Из цФайл.ТаблицаПокрытия() Цикл
			
			номерСтроки = Формат( цСтрока.Номер, "ЧГ=" );

			Если цСтрока.Покрыто Тогда

				покрыто = "true";

			Иначе
				
				покрыто = "false";

			КонецЕсли;

			Запись.ЗаписатьНачалоЭлемента("lineToCover");
			Запись.ЗаписатьАтрибут("lineNumber", номерСтроки );
			Запись.ЗаписатьАтрибут("covered", покрыто);
			Запись.ЗаписатьКонецЭлемента();
			
		КонецЦикла;
		
		Запись.ЗаписатьКонецЭлемента();
		
	КонецЦикла;
	
	Запись.ЗаписатьКонецЭлемента();
	
	Запись.Закрыть();
	
	_Лог.Информация("Результаты конвертации записаны в %1", _ПутьКФайлуПокрытия);
	
КонецПроцедуры

#КонецОбласти



