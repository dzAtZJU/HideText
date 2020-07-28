//
//  ViewController.swift
//  HideText
//
//  Created by Zhou Wei Ran on 2020/7/27.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, NSLayoutManagerDelegate {

    let textView: UITextView = {
        let r = UITextView()
        r.font = UIFont.preferredFont(forTextStyle: .title3)
        return r
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(textView)
        
        textView.layoutManager.delegate = self
    }
    
    override func viewSafeAreaInsetsDidChange() {
         textView.frame = view.bounds.inset(by: view.safeAreaInsets)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int {
        // First, make sure we'll be able to access the NSTextStorage.
        guard let textStorage = layoutManager.textStorage else {
            fatalError("No textStorage was associated to this layoutManager")
        }

        // Access the characters.
        let utf16CodeUnits = textStorage.string.utf16
        var modifiedGlyphProperties = [NSLayoutManager.GlyphProperty]()
        for i in 0 ..< glyphRange.length {
            var glyphProperties = props[i]
            let character = characterFromUTF16CodeUnits(utf16CodeUnits, at: charIndexes[i])

            // Do something with `character`, e.g.:
            if character == "*" {
                glyphProperties.insert(.null)
            }

            modifiedGlyphProperties.append(glyphProperties)
        }

        // Convert our Swift array to the UnsafePointer `setGlyphs` expects.
        modifiedGlyphProperties.withUnsafeBufferPointer { modifiedGlyphPropertiesBufferPointer in
            guard let modifiedGlyphPropertiesPointer = modifiedGlyphPropertiesBufferPointer.baseAddress else {
                fatalError("Could not get base address of modifiedGlyphProperties")
            }

            // Call setGlyphs with the modified array.
            layoutManager.setGlyphs(glyphs, properties: modifiedGlyphPropertiesPointer, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
        }

        return glyphRange.length
    }
    
    /// Returns the extended grapheme cluster at `index` in an UTF16View, merging a UTF-16 surrogate pair if needed.
    private func characterFromUTF16CodeUnits(_ utf16CodeUnits: String.UTF16View, at index: Int) -> Character {
        let codeUnitIndex = utf16CodeUnits.index(utf16CodeUnits.startIndex, offsetBy: index)
        let codeUnit = utf16CodeUnits[codeUnitIndex]

        if UTF16.isLeadSurrogate(codeUnit) {
            let nextCodeUnit = utf16CodeUnits[utf16CodeUnits.index(after: codeUnitIndex)]
            let codeUnits = [codeUnit, nextCodeUnit]
            let str = String(utf16CodeUnits: codeUnits, count: 2)
            return Character(str)
        } else if UTF16.isTrailSurrogate(codeUnit) {
            let previousCodeUnit = utf16CodeUnits[utf16CodeUnits.index(before: codeUnitIndex)]
            let codeUnits = [previousCodeUnit, codeUnit]
            let str = String(utf16CodeUnits: codeUnits, count: 2)
            return Character(str)
        } else {
            let unicodeScalar = UnicodeScalar(codeUnit)!
            return Character(unicodeScalar)
        }
    }

}
