//
//  CardExporter.swift
//  CozyNCLEX Prep 2026
//
//  Utility to export bundled flashcards to Supabase SQL format
//

import Foundation

struct CardExporter {

    /// Export all bundled flashcards to SQL INSERT statements
    /// Call this once from a debug view, then copy from console to Supabase SQL Editor
    static func exportToSQL() -> String {
        var sql = """
        -- Auto-generated SQL for nclex_questions table
        -- Generated from bundled app cards

        -- First, create the version entry
        INSERT INTO content_versions (version, is_current)
        VALUES ('1.0.0', true)
        ON CONFLICT (version) DO UPDATE SET is_current = true;

        -- Insert all questions

        """

        let allCards = Flashcard.freeCards + Flashcard.premiumCards

        for card in allCards {
            let escapedQuestion = card.question.replacingOccurrences(of: "'", with: "''")
            let escapedAnswer = card.answer.replacingOccurrences(of: "'", with: "''")
            let escapedRationale = card.rationale.replacingOccurrences(of: "'", with: "''")

            // Convert wrong answers array to JSON
            let wrongAnswersJSON = card.wrongAnswers.map { answer in
                "\"\(answer.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "'", with: "''"))\""
            }.joined(separator: ", ")

            // Map enum values to database format
            let contentCategory = card.contentCategory.rawValue
            let nclexCategory = card.nclexCategory.rawValue
            let difficulty = card.difficulty.rawValue
            let questionType = card.questionType.rawValue

            sql += """
            INSERT INTO nclex_questions (id, question, answer, wrong_answers, rationale, content_category, nclex_category, difficulty, question_type, is_premium, is_active, version)
            VALUES (
                '\(card.id.uuidString)',
                '\(escapedQuestion)',
                '\(escapedAnswer)',
                '[\(wrongAnswersJSON)]',
                '\(escapedRationale)',
                '\(contentCategory)',
                '\(nclexCategory)',
                '\(difficulty)',
                '\(questionType)',
                \(card.isPremium),
                true,
                '1.0.0'
            );

            """
        }

        sql += "\n-- Total cards exported: \(allCards.count)\n"

        return sql
    }

    /// Export to JSON format (alternative for Supabase import)
    static func exportToJSON() -> String {
        let allCards = Flashcard.freeCards + Flashcard.premiumCards

        let jsonCards = allCards.map { card -> [String: Any] in
            return [
                "id": card.id.uuidString,
                "question": card.question,
                "answer": card.answer,
                "wrong_answers": card.wrongAnswers,
                "rationale": card.rationale,
                "content_category": card.contentCategory.rawValue,
                "nclex_category": card.nclexCategory.rawValue,
                "difficulty": card.difficulty.rawValue,
                "question_type": card.questionType.rawValue,
                "is_premium": card.isPremium,
                "is_active": true,
                "version": "1.0.0"
            ]
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonCards, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }

        return "[]"
    }

    /// Print export to console (call from debug)
    static func printSQLExport() {
        print("=== BEGIN SQL EXPORT ===")
        print(exportToSQL())
        print("=== END SQL EXPORT ===")
    }

    /// Save SQL to file in Documents directory
    static func saveSQLToFile() -> URL? {
        let sql = exportToSQL()

        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentsURL.appendingPathComponent("nclex_questions_export.sql")

        do {
            try sql.write(to: fileURL, atomically: true, encoding: .utf8)
            print("SQL exported to: \(fileURL.path)")
            return fileURL
        } catch {
            print("Failed to save SQL: \(error)")
            return nil
        }
    }

    /// Save JSON to file in Documents directory
    static func saveJSONToFile() -> URL? {
        let json = exportToJSON()

        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = documentsURL.appendingPathComponent("nclex_questions_export.json")

        do {
            try json.write(to: fileURL, atomically: true, encoding: .utf8)
            print("JSON exported to: \(fileURL.path)")
            return fileURL
        } catch {
            print("Failed to save JSON: \(error)")
            return nil
        }
    }
}
