import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Scanner;
import oracle.jdbc.*;
import java.sql.ResultSet;

public class DigitalStockMarket {
    private static final String JDBC_URL = "jdbc:oracle:thin:@localhost:1521:xe"; // Replace localhost and xe with your Oracle DB host and SID
    private static final String DB_USER = "dsm";
    private static final String DB_PASSWORD = "dsm";

    public static void main(String[] args) {
        try (Connection connection = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {
            Scanner scanner = new Scanner(System.in);
            boolean exit = false;

            while (!exit) {
                System.out.println("Choose an option:\n" +
                        " 1. Signup\n" +
                        " 2. Login\n" +
                        " 3. View Company List\n" +
                        " 4. View Company Details\n" +
                        " 5. Buy Stocks\n" +
                        " 6. Sell Stocks\n" +
                        " 7. View Portfolio\n" +
                        " 8. Exit");
                System.out.print("Enter your choice: ");
                int choice = scanner.nextInt();
                scanner.nextLine();  // Consume newline

                switch (choice) {
                    case 8:
                        exit = true;
                        System.out.println("Exiting the application.");
                        break;


                    case 5:
                        System.out.println("Enter your user ID:");
                        int NEWuserId = scanner.nextInt();
                        scanner.nextLine(); // Consume newline

                        System.out.println("Enter the company ID you want to buy:");
                        int companyId = scanner.nextInt();
                        scanner.nextLine(); // Consume newline

                        System.out.println("Enter the number of stocks you want to buy:");
                        int quantity = scanner.nextInt();
                        scanner.nextLine(); // Consume newline4

                        buyStock(connection, NEWuserId, companyId, quantity);
                        break;

                    case 6:
                        System.out.println("Enter your user ID:");
                        int sellUserId = scanner.nextInt();
                        scanner.nextLine(); // Consume newline

                        System.out.println("Enter company ID you want to sell:");
                        int sellCompanyId = scanner.nextInt();
                        scanner.nextLine(); // Consume newline

                        System.out.println("Enter the number of stocks you want to sell:");
                        int sellQuantity = scanner.nextInt();
                        scanner.nextLine(); // Consume newline

                        sellStock(connection, sellUserId, sellCompanyId, sellQuantity);
                        break;

                    case 7:
                        // View Portfolio
                        System.out.println("Enter user ID to view Portfolio :");
                        int viewUserId = scanner.nextInt();
                        scanner.nextLine(); // Consume newline
                        viewPortfolio(connection, viewUserId);
                        break;
                }

                
    public static void buyStock(Connection connection, int userId, int companyId, int quantity) throws SQLException {
        String sql = "{call buy_stock(?, ?, ?)}";
        try (CallableStatement stmt = connection.prepareCall(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, companyId);
            stmt.setInt(3, quantity);
            stmt.execute();
            System.out.println("Stock purchase successfully for user " + userId);
        }
        catch (SQLException e) {
            // Extract the error message from the SQLException
            String errorMessage = e.getMessage();
            System.out.println(errorMessage);
        }

    }

    public static void sellStock(Connection connection, int userId, int companyId, int quantity) throws SQLException {
        String sql = "{call sell_stock(?, ?, ?)}";
        try (CallableStatement stmt = connection.prepareCall(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, companyId);
            stmt.setInt(3, quantity);
            stmt.execute();
            System.out.println("Stock sold successfully for user " + userId);
        } catch (SQLException e) {
            // Extract the error message from the SQLException
            String errorMessage = e.getMessage();
            System.out.println(errorMessage);
        }
    }


    public static void viewPortfolio(Connection connection, int userId) throws SQLException {
        String sql = "{call view_portfolio(?, ?)}";
        try (CallableStatement stmt = connection.prepareCall(sql)) {
            stmt.setInt(1, userId);
            stmt.registerOutParameter(2, OracleTypes.CURSOR); // Register the OUT parameter
            stmt.execute();



            // Get the result set from the stored procedure
            ResultSet rs = (ResultSet) stmt.getObject(2);

            // Iterate over the result set and print portfolio details
            while (rs.next()) {
                String username = rs.getString("username");
                String email = rs.getString("email");
                String bankAccount = rs.getString("bank_account");
                String contactNumber = rs.getString("contact_number");
                double wallet = rs.getDouble("wallet");
                int companyId = rs.getInt("company_id");
                String companyName = rs.getString("company_name");
                int quantity = rs.getInt("quantity");

                if(rs.isFirst()) {
                    System.out.println("Username: " + username);
                    System.out.println("Email: " + email);
                    System.out.println("Bank Account: " + bankAccount);
                    System.out.println("Contact Number: " + contactNumber);
                    System.out.println("Wallet: " + wallet);
                }
                System.out.println("Company ID: " + companyId);
                System.out.println("Company Name: " + companyName);
                System.out.println("Quantity: " + quantity);
                System.out.println();
            }
        }


    }
