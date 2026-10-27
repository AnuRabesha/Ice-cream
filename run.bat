@echo off
SET JAVA="C:\Program Files\Java\jdk-17\bin\javac.exe"
SET JAVAHOME="C:\Program Files\Java\jdk-17\bin\java.exe"
SET SRC=C:\Users\micha\Documents\Java Project\src
SET OUT=C:\tomcat9\webapps\scoopora\WEB-INF\classes
SET LIB=C:\tomcat9\webapps\scoopora\WEB-INF\lib
SET SERVLET=C:\tomcat9\lib\servlet-api.jar
SET CP=%SERVLET%;%LIB%\sqlite-jdbc-3.43.0.0.jar;%LIB%\jstl-1.2.jar;%LIB%\bcrypt-0.10.2.jar;%LIB%\bytes-1.5.0.jar

echo === Compiling Scoopora ===

%JAVA% -encoding UTF-8 -cp "%CP%" -d "%OUT%" -sourcepath "%SRC%" ^
  "%SRC%\com\scoopora\db\DBConnection.java" ^
  "%SRC%\com\scoopora\db\DBInit.java" ^
  "%SRC%\com\scoopora\db\AppContextListener.java" ^
  "%SRC%\com\scoopora\model\BusinessAccount.java" ^
  "%SRC%\com\scoopora\model\CakeDesign.java" ^
  "%SRC%\com\scoopora\model\CustomCakeOrder.java" ^
  "%SRC%\com\scoopora\model\Flavour.java" ^
  "%SRC%\com\scoopora\model\Order.java" ^
  "%SRC%\com\scoopora\model\Product.java" ^
  "%SRC%\com\scoopora\model\Review.java" ^
  "%SRC%\com\scoopora\model\Shop.java" ^
  "%SRC%\com\scoopora\model\User.java" ^
  "%SRC%\com\scoopora\servlet\AuthServlet.java" ^
  "%SRC%\com\scoopora\servlet\BulkOrderServlet.java" ^
  "%SRC%\com\scoopora\servlet\BusinessAuthServlet.java" ^
  "%SRC%\com\scoopora\servlet\BusinessDashboardServlet.java" ^
  "%SRC%\com\scoopora\servlet\BusinessOrderServlet.java" ^
  "%SRC%\com\scoopora\servlet\CakeServlet.java" ^
  "%SRC%\com\scoopora\servlet\CartCountServlet.java" ^
  "%SRC%\com\scoopora\servlet\CartServlet.java" ^
  "%SRC%\com\scoopora\servlet\CheckoutServlet.java" ^
  "%SRC%\com\scoopora\servlet\CustomCakeServlet.java" ^
  "%SRC%\com\scoopora\servlet\FlavoursServlet.java" ^
  "%SRC%\com\scoopora\servlet\HomeServlet.java" ^
  "%SRC%\com\scoopora\servlet\InventoryServlet.java" ^
  "%SRC%\com\scoopora\servlet\MoodServlet.java" ^
  "%SRC%\com\scoopora\servlet\OrderServlet.java" ^
  "%SRC%\com\scoopora\servlet\ReviewServlet.java" ^
  "%SRC%\com\scoopora\servlet\SearchServlet.java" ^
  "%SRC%\com\scoopora\servlet\ShopServlet.java" ^
  "%SRC%\com\scoopora\servlet\SupplierCompareServlet.java"

IF %ERRORLEVEL% EQU 0 (
  echo === COMPILE SUCCESS ===
) ELSE (
  echo === COMPILE FAILED - Check errors above ===
  pause
  exit /b 1
)

echo === Copying schema ===
copy /Y "C:\Users\micha\Documents\Java Project\database\schema_sqlite.sql" "%OUT%\schema_sqlite.sql"

echo === Starting Tomcat ===
SET JAVA_HOME=C:\Program Files\Java\jdk-17
SET CATALINA_HOME=C:\tomcat9
call C:\tomcat9\bin\startup.bat

echo === Tomcat started ===
echo Open browser: http://localhost:8080/scoopora/home
pause
