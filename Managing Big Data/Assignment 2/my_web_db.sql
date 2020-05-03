-- MySQL Script generated by MySQL Workbench
-- Mon Jan 27 01:42:16 2020
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema my_web_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema my_web_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `my_web_db` DEFAULT CHARACTER SET utf8 ;
USE `my_web_db` ;

-- -----------------------------------------------------
-- Table `my_web_db`.`Users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `my_web_db`.`Users` (
  `User_ID` INT NOT NULL AUTO_INCREMENT,
  `Email_Address` VARCHAR(45) NOT NULL,
  `First_Name` VARCHAR(45) NOT NULL,
  `Last_Name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`User_ID`),
  UNIQUE INDEX `User_ID_UNIQUE` (`User_ID` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `my_web_db`.`Product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `my_web_db`.`Product` (
  `Product_ID` INT NOT NULL AUTO_INCREMENT,
  `Product_Name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Product_ID`),
  UNIQUE INDEX `Product_ID_UNIQUE` (`Product_ID` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `my_web_db`.`Download`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `my_web_db`.`Download` (
  `Download_ID` INT NOT NULL AUTO_INCREMENT,
  `Filename` VARCHAR(45) NOT NULL,
  `Date/Time` DATETIME NOT NULL,
  `Users_User_ID` INT NOT NULL,
  `Product_Product_ID` INT NOT NULL,
  PRIMARY KEY (`Download_ID`),
  UNIQUE INDEX `Download_ID_UNIQUE` (`Download_ID` ASC) VISIBLE,
  INDEX `fk_Download_Users_idx` (`Users_User_ID` ASC) VISIBLE,
  INDEX `fk_Download_Product1_idx` (`Product_Product_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Download_Users`
    FOREIGN KEY (`Users_User_ID`)
    REFERENCES `my_web_db`.`Users` (`User_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Download_Product1`
    FOREIGN KEY (`Product_Product_ID`)
    REFERENCES `my_web_db`.`Product` (`Product_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
