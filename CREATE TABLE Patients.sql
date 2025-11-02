CREATE DATABASE IF NOT EXISTS MedManageDB;
USE MedManageDB;

INSERT INTO appointment (
    AppointmentID,
    PatientUserID,
    DoctorUserID,
    AppointmentOn,
    Details
  )
VALUES (
    AppointmentID:int,
    PatientUserID:int,
    DoctorUserID:int,
    'AppointmentOn:date',
    'Details:varchar'
  );

  INSERT INTO `user` (`UserId`, `Name`, `Email`, `PhoneNumber`, `Password`, `UserType`, `InstituteID`) VALUES
(1, 'Admin One', 'admin1@medmanage.com', '0111111111', 'hashed_admin1', 'superadmin', NULL),
(2, 'Dr. Sarah Tan', 'sarah.tan@hospitala.com', '0122222222', 'hashed_sarah', 'doctor', 101),
(3, 'Dr. Amir Rahman', 'amir.rahman@hospitalb.com', '0133333333', 'hashed_amir', 'doctor', 102),
(4, 'Dr. Rebecca Lee', 'rebecca.lee@hospitala.com', '0144444444', 'hashed_rebecca', 'doctor', 101),
(5, 'Dr. Jason Chong', 'jason.chong@hospitalc.com', '0155555555', 'hashed_jason', 'doctor', 103),
(6, 'Alice Lim', 'alice.lim@gmail.com', '0166666666', 'hashed_alice', 'patient', 101),
(7, 'Daniel Ng', 'daniel.ng@gmail.com', '0177777777', 'hashed_daniel', 'patient', 102),
(8, 'Nur Aina', 'nur.aina@yahoo.com', '0188888888', 'hashed_aina', 'patient', 103),
(9, 'Kelvin Wong', 'kelvin.wong@gmail.com', '0199999999', 'hashed_kelvin', 'patient', 101),
(10, 'Admin Two', 'admin2@medmanage.com', '0101010101', 'hashed_admin2', 'admin', NULL);
(11, 'Shaughn Ibel', 'sibel0@prlog.org', '0112345678', 'hashed_sibel', 'patient', 101),
(12, 'Gui Langstrath', 'glangstrath1@hubpages.com', '0112345679', 'hashed_gui', 'patient', 101),
(13, 'Dale MacAllaster', 'dmacallaster2@yolasite.com', '0112345680', 'hashed_dale', 'patient', 101),
(14, 'Corrine Penzer', 'cpenzer3@go.com', '0112345681', 'hashed_corrine', 'patient', 101),
(15, 'Gerri Croci', 'gcroci4@simplemachines.org', '0112345682', 'hashed_gerri', 'patient', 101),
(16, 'Bethina Shipman', 'bshipman5@theglobeandmail.com', '0112345683', 'hashed_bethina', 'patient', 101),
(17, 'Bambi Edmundson', 'bedmundson6@comsenz.com', '0112345684', 'hashed_bambi', 'patient', 101),
(18, 'Michaela Tremblet', 'mtremblet7@wufoo.com', '0112345685', 'hashed_michaela', 'patient', 101),
(19, 'Meryl Copo', 'mcopo8@gmpg.org', '0112345686', 'hashed_meryl', 'patient', 101),
(20, 'Clareta Haughey', 'chaughey9@google.ru', '0112345687', 'hashed_clareta', 'patient', 101),
(21, 'Cristie Bugdell', 'cbugdella@mapy.cz', '0112345688', 'hashed_cristie', 'patient', 101),
(22, 'Brittni Antecki', 'banteckib@earthlink.net', '0112345689', 'hashed_brittni', 'patient', 101),
(23, 'Reinhard Engley', 'rengleyc@multiply.com', '0112345690', 'hashed_reinhard', 'patient', 101),
(24, 'Atalanta Driscoll', 'aodriscolld@plala.or.jp', '0112345691', 'hashed_atalanta', 'patient', 101),
(25, 'Lucita Priscott', 'lpriscotte@xinhuanet.com', '0112345692', 'hashed_lucita', 'patient', 101),
(26, 'Lianna Dunlop', 'ldunlopf@histats.com', '0112345693', 'hashed_lianna', 'patient', 101),
(27, 'Daren Stovin', 'dstoving@moonfruit.com', '0112345694', 'hashed_daren', 'patient', 101),
(28, 'Marya McCraine', 'mmccraineh@miibeian.gov.cn', '0112345695', 'hashed_marya', 'patient', 101),
(29, 'Augustine Blackler', 'ablackleri@nhs.uk', '0112345696', 'hashed_augustine', 'patient', 101),
(30, 'Neville Lazell', 'nlazellj@facebook.com', '0112345697', 'hashed_neville', 'patient', 101),
(31, 'Alina Watton', 'awattonk@smh.com.au', '0112345698', 'hashed_alina', 'patient', 101),
(32, 'Maud Scholey', 'mscholeyl@oaic.gov.au', '0112345699', 'hashed_maud', 'patient', 101),
(33, 'Grannie Larsen', 'glarsenm@gravatar.com', '0112345700', 'hashed_grannie', 'patient', 101),
(34, 'Reeba Aingel', 'raingeln@ox.ac.uk', '0112345701', 'hashed_reeba', 'patient', 101),
(35, 'Sunny Reburn', 'sreburno@gravatar.com', '0112345702', 'hashed_sunny', 'patient', 101),
(36, 'Sarah Piborn', 'spibornp@narod.ru', '0112345703', 'hashed_sarahp', 'patient', 101),
(37, 'Maribel Glanders', 'mglandersq@indiegogo.com', '0112345704', 'hashed_maribel', 'patient', 101),
(38, 'Sharla Ashfold', 'sashfoldr@amazon.com', '0112345705', 'hashed_sharla', 'patient', 101),
(39, 'Frasquito Nise', 'fnises@fc2.com', '0112345706', 'hashed_frasquito', 'patient', 101),
(40, 'Aurelia Durston', 'adurstont@youtube.com', '0112345707', 'hashed_aurelia', 'patient', 101),
(41, 'Eachelle Spurgin', 'espurginu@nationalgeographic.com', '0112345708', 'hashed_eachelle', 'patient', 101),
(42, 'Channa Gorman', 'cogormanv@youtube.com', '0112345709', 'hashed_channa', 'patient', 101),
(43, 'Xylina Bassilashvili', 'xbassilashviliw@skyrock.com', '0112345710', 'hashed_xylina', 'patient', 101),
(44, 'Yoshiko Rylance', 'yrylancex@scribd.com', '0112345711', 'hashed_yoshiko', 'patient', 101),
(45, 'Dierdre Hardwich', 'dhardwichy@merriam-webster.com', '0112345712', 'hashed_dierdre', 'patient', 101),
(46, 'Ansley Sikora', 'asikoraz@bing.com', '0112345713', 'hashed_ansley', 'patient', 101),
(47, 'Colman Paszak', 'cpaszak10@japanpost.jp', '0112345714', 'hashed_colman', 'patient', 101),
(48, 'Alexi Le Barr', 'alebarr11@youtube.com', '0112345715', 'hashed_alexi', 'patient', 101),
(49, 'Lenee Jirus', 'ljirus12@bandcamp.com', '0112345716', 'hashed_lenee', 'patient', 101);
(50, 'Tomas Eldridge', 'teldridge13@healthline.com', '0112345717', 'hashed_tomas', 'patient', 101);

