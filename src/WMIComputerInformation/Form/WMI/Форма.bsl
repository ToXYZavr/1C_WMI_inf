﻿// Переменные использующиеся в нескольких процедурах.
&НаКлиенте
Перем ServicesSet Экспорт ;

&НаКлиенте
Перем СоответствиеСвойств Экспорт ;

// Процедура заполняет поля при открытии формы.
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	NameSpace="root\cimv2";
	
	Элементы.NetPC.Видимость=Ложь;
	
КонецПроцедуры

// Обработка нажатия на кнопку "Сформировать".
//
// Основная обработка формы, через которую мы обращаемся к компаненту
// WbemScripting.SWbemLocator, как к COM - объекту
&НаКлиенте
Процедура Сформировать(Команда)
	
	Попытка
		
		Locator = Новый COMОбъект("WbemScripting.SWbemLocator");
		
	Исключение
		
		Сообщить(ОписаниеОшибки());
		
		Возврат;
		
	КонецПопытки;
	
	если Переключатель=Истина тогда
	
		если NameNet<>"" и NameSpace<>"" и User<>"" и Password<>"" тогда
			
			Попытка
				
				ServicesSet = Locator.ConnectServer(NameNet, NameSpace, User, Password);
				
			Исключение
				
		 		Сообщить("Отказано в доступе. Возможно, недостаточно прав или не установлены компоненты WMI.	"+ОписаниеОшибки());
				
		 		Возврат;
				
			КонецПопытки;
			
		иначе
			
			Сообщить("Не все поля, для доступа к удаленному компьютеру, заполнены.");
			
			Возврат;
			
		КонецЕсли;
	
	иначе
		
		Попытка
			
	 		ServicesSet = Locator.ConnectServer("."); // по умолчанию, текущая машина
			
		Исключение
			
	 		Сообщить("Отказано в доступе. Возможно, недостаточно прав или не установлены компоненты WMI.	"+ОписаниеОшибки());
			
	 		Возврат;
			
		КонецПопытки;
		
	КонецЕсли;
	
	СоответствиеСвойств = Новый Соответствие();
	
	Устройство.ПолучитьЭлементы().Очистить();
	
	ВывестиУстройства("Общие", "Win32_ComputerSystem"); 
	
	ВывестиУстройства("Операционные системы", "Win32_OperatingSystem");
	
	ВывестиУстройства("Службы", "Win32_Service");
	
	ВывестиУстройства("Запущенные процессы", "Win32_Process");
	
	ВывестиУстройства("Командах автозагрузки", "Win32_StartupCommand");
	
	//ВывестиУстройства("Пользователи и группы", "Win32_Account"); // исключил. долго обрабатывается
	
	ВывестиУстройства("Общие ресурсы", "Win32_Share");
	
	ВывестиУстройства("BIOS", "Win32_BIOS");  
	
	ВывестиУстройства("Материнская плата", "Win32_BaseBoard");
	
	ВывестиУстройства("Процессоры", "Win32_Processor");
	
	ВывестиУстройства("Устройства мат. платы", "Win32_OnBoardDevice");
	
	ВывестиУстройства("Физическая шина", "Win32_Bus");
	
	ВывестиУстройства("Физическая память (RAM)", "Win32_PhysicalMemory");
	
	ВывестиУстройства("USB Hub", "Win32_USBHub");
	
	ВывестиУстройства("Дисковые накопители (HDD)", "Win32_DiskDrive");    
	
	ВывестиУстройства("Дисковые разделы (HDD)", "Win32_DiskPartition");
	
	ВывестиУстройства("Звуковые карты", "Win32_SoundDevice");
	
	ВывестиУстройства("Сетевые адаптеры", "Win32_NetworkAdapter");
	
	ВывестиУстройства("CD-ROM приводы", "Win32_CDROMDrive"); 
	
	ВывестиУстройства("Floppy-дисководы", "Win32_FloppyDrive");
	
	ВывестиУстройства("Видео система", "Win32_VideoController");
	
	ВывестиУстройства("Мониторы", "Win32_DesktopMonitor");
	
	ВывестиУстройства("Принтеры", "Win32_Printer");
	
	ВывестиУстройства("Клавиатуры", "Win32_Keyboard");
	
	ВывестиУстройства("Точечные манипуляторы", "Win32_PointingDevice");
	
КонецПроцедуры

// Формируем соответствия по свойствам.
&НаКлиенте
Процедура ВывестиУстройства(Заголовок, Путь)
	
	СтрокаТП = Устройство.ПолучитьЭлементы().Добавить();
	
	СтрокаТП.Категория = Заголовок;
	
	pEnum = ServicesSet.InstancesOf(Путь);
	
	Для каждого Object Из pEnum Цикл
		
		ПодСтрокаТП = СтрокаТП.ПолучитьЭлементы().Добавить();
		
		ПодСтрокаТП.Категория = Object.Caption;
		
		СоответствиеСвойств.Вставить(ПодСтрокаТП, Object.Properties_);
		
	КонецЦикла;
	
КонецПроцедуры

// формируем значения свойств в выбранном разделе
// и стараемся преобразовать и интерпритировать 
// значения в удобном для понимании виде.
&НаКлиенте
Процедура УстройствоПриАктивизацииСтроки(Элемент)
	
	если Элемент.ТекущиеДанные=Неопределено тогда
		
		возврат;
		
	КонецЕсли;
	
	СвойстваСп.Очистить();
	
	КоллекцияСвойств = СоответствиеСвойств.Получить(Элемент.ТекущиеДанные);
	
	Если не (КоллекцияСвойств = Неопределено) Тогда
		
		Для каждого Свойство Из КоллекцияСвойств Цикл
			
			если Свойство.Value<>Null и Свойство.IsArray<>Истина и Свойство.CIMType<>0 и Свойство.CIMType<>13 и Свойство.CIMType<>102 и Лев(Свойство.Value,5)<>"Win32" тогда //не выводить свойства если они null или массив или не формат
				                                                   
				СтрокаТП = СвойстваСп.Добавить();
				
				СтрокаТП.ИмяСвойства = Свойство.Name;
				
				если Свойство.CIMType=101 тогда //дата и время
					
					переВ=Дата(Лев(Свойство.Value,14));
					
				иначеесли Свойство.CIMType=11 тогда //булево
					
					переВ=Свойство.Value;
					
				иначеесли Свойство.CIMType=8 или Свойство.CIMType=103 тогда //текст
					
					переВ=Свойство.Value;	
					
				иначеесли Свойство.CIMType=4 или Свойство.CIMType=5  тогда //числа с запятой
					
					переВ=Формат(Свойство.Value,"ЧДЦ=3; ЧН=0; ЧГ=0; ЧО=1");
					
				иначеесли Свойство.CIMType=2 или Свойство.CIMType=3 или Свойство.CIMType=20 или Свойство.CIMType=16 или Свойство.CIMType=18 или Свойство.CIMType=21 или Свойство.CIMType=17  тогда //целочисленное значение
					
					переВ=Формат(Свойство.Value,"ЧДЦ=0; ЧН=0; ЧГ=0; ЧО=1");	
					
				КонецЕсли;
				
				СтрокаТП.Значение = переВ;
				
			КонецЕсли;
			
		КонецЦикла; 
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура управления видимостью элементов.
&НаКлиенте
Процедура ПереключательПриИзменении(Элемент)
	
	если Переключатель=Истина тогда
		
		Элементы.NetPC.Видимость=Истина;
		
	иначе
		
		Элементы.NetPC.Видимость=Ложь;
		
	КонецЕсли;
	
КонецПроцедуры
