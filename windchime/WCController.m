//
//  WCController.m
//  windchime
//
//  Created by Tom MacWright on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WCController.h"
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>

enum {
    kMidiMessageNoteOn        = 0x90,
    kMidiMessageNoteOff       = 0x80,
    kMidiMessageBassOn        = 0x91,
    kMidiMessageBassOff       = 0x81,
    kMidiMessageChordOn       = 0x92,
    kMidiMessageChordOff      = 0x82,
    kMidiMessageControlChange = 0xB0,
    kMidiMessageProgramChange = 0xC0};

@implementation WCController
- (id)init
{
    self = [super init];
    if (self)
    {
        
        
        char *instruments[] =
        {"Acoustic Grand Piano", "Bright Acoustic Piano",
            "Electric Grand Piano", "Honky-tonk Piano",
            "Electric Piano 1", "Electric Piano 2", "Harpsichord",
            "Clavi", "Celesta", "Glockenspiel", "Music Box",
            "Vibraphone", "Marimba", "Xylophone", "Tubular Bells",
            "Dulcimer", "Drawbar Organ", "Percussive Organ",
            "Rock Organ", "Church Organ", "Reed Organ",
            "Accordion", "Harmonica", "Tango Accordion",
            "Acoustic Guitar (nylon)", "Acoustic Guitar (steel)",
            "Electric Guitar (jazz)", "Electric Guitar (clean)",
            "Electric Guitar (muted)", "Overdriven Guitar",
            "Distortion Guitar", "Guitar harmonics",
            "Acoustic Bass", "Electric Bass (finger)",
            "Electric Bass (pick)", "Fretless Bass",
            "Slap Bass 1", "Slap Bass 2", "Synth Bass 1",
            "Synth Bass 2", "Violin", "Viola", "Cello",
            "Contrabass", "Tremolo Strings", "Pizzicato Strings",
            "Orchestral Harp", "Timpani", "String Ensemble 1",
            "String Ensemble 2", "SynthStrings 1", "SynthStrings 2",
            "Choir Aahs", "Voice Oohs", "Synth Voice",
            "Orchestra Hit", "Trumpet", "Trombone", "Tuba",
            "Muted Trumpet", "French Horn", "Brass Section",
            "SynthBrass 1", "SynthBrass 2", "Soprano Sax",
            "Alto Sax", "Tenor Sax", "Baritone Sax", "Oboe",
            "English Horn", "Bassoon", "Clarinet", "Piccolo",
            "Flute", "Recorder", "Pan Flute", "Blown Bottle",
            "Shakuhachi", "Whistle", "Ocarina", "Lead 1 (square)",
            "Lead 2 (sawtooth)", "Lead 3 (calliope)", "Lead 4 (chiff)",
            "Lead 5 (charang)", "Lead 6 (voice)", "Lead 7 (fifths)",
            "Lead 8 (bass + lead)", "Pad 1 (new age)", "Pad 2 (warm)",
            "Pad 3 (polysynth)", "Pad 4 (choir)", "Pad 5 (bowed)",
            "Pad 6 (metallic)", "Pad 7 (halo)", "Pad 8 (sweep)",
            "FX 1 (rain)", "FX 2 (soundtrack)", "FX 3 (crystal)",
            "FX 4 (atmosphere)", "FX 5 (brightness)", "FX 6 (goblins)",
            "FX 7 (echoes)", "FX 8 (sci-fi)", "Sitar", "Banjo",
            "Shamisen", "Koto", "Kalimba", "Bag pipe", "Fiddle",
            "Shanai", "Tinkle Bell", "Agogo", "Steel Drums",
            "Woodblock", "Taiko Drum", "Melodic Tom", "Synth Drum",
            "Reverse Cymbal", "Guitar Fret Noise", "Breath Noise",
            "Seashore", "Bird Tweet", "Telephone Ring",
            "Helicopter", "Applause", "Gunshot"};
        
        
        NSString* tinyName = [[NSBundle mainBundle]
                              pathForResource:@"windchime"
                              ofType:@"png"];
        
        tiny = [[NSImage alloc] initWithContentsOfFile:tinyName];
        menu = [[NSMenu alloc] init];
        
        // Set up my status item
        statusItem = [[NSStatusBar systemStatusBar]
                       statusItemWithLength:NSVariableStatusItemLength];
        
        [statusItem setMenu:menu];
        [statusItem setToolTip:@"all keys"];
        [statusItem setImage:tiny];
        [statusItem setHighlightMode:YES];
        // Set up the menu
        quitMI = [[NSMenuItem alloc]
                   initWithTitle:NSLocalizedString(@"Quit",@"") 
                   action:@selector(terminate:) 
                  keyEquivalent:@""];
        
        [menu addItem:quitMI];
    }

    AudioUnit synthUnit;
    
    
    // Audio Unit graph
    
    AUGraph graph;
    
    // Audio Unit synthesizer and output node
    
    AUNode synthNode;
    AUNode outNode;
    
    // Component description
    
    ComponentDescription cd;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    
    // New AU graph
    
    NewAUGraph(&graph);
    
    // Synthesizer
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_DLSSynth;
    // New synthesizer node
    AUGraphNewNode(graph, &cd, 0, NULL, &synthNode);
    // Output
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_DefaultOutput;
    // New output node
    AUGraphNewNode(graph, &cd, 0, NULL, &outNode);
    // Open graph
    AUGraphOpen(graph);
    // Connect synthesizer node to output node
    AUGraphConnectNodeInput(graph, synthNode, 0, outNode, 0);
    // Get a synthesizer unit
    AUGraphGetNodeInfo(graph, synthNode, NULL, 0, NULL, &synthUnit);
    // Initialise
    AUGraphInitialize(graph);
    
    // Start
    AUGraphStart(graph);
    
    // Change instrument
    int instrument = 10;
    
    MusicDeviceMIDIEvent(synthUnit, kMidiMessageProgramChange + 0,
                         instrument, 0, 0);
    MusicDeviceMIDIEvent(synthUnit, kMidiMessageProgramChange + 1,
                         instrument, 0, 0);
    MusicDeviceMIDIEvent(synthUnit, kMidiMessageProgramChange + 2,
                         instrument, 0, 0);
    
    __block int level = 3;
    
    const int c = 24,
        d = 26,
        e = 28,
        f = 29,
        g = 31,
        a = 33,
        b = 35;
    
    [NSEvent
     addGlobalMonitorForEventsMatchingMask:NSKeyDownMask
     handler:^ (NSEvent *event) {
         int note = 0;
         int volume = 100;
         if ([[event characters] isEqualToString:@"["] ||
             [[event characters] isEqualToString:@"{"] ||
             [[event characters] isEqualToString:@"("]) {
             note = g + (12 * level);
             level++;
         }
         else if ([[event characters] isEqualToString:@"]"] ||
                  [[event characters] isEqualToString:@"}"] ||
                  [[event characters] isEqualToString:@")"]) {
             note = c + (12 * level);
             level--;
         }
         else if ([[event characters] isEqualToString:@"'"] ||
                  [[event characters] isEqualToString:@"\""]) {
             volume = 40;
             note = d + (12 * level);
         }
         else if ([[event characters] isEqualToString:@";"] ||
                  [[event characters] isEqualToString:@","]) {
             volume = 40;
             note = f + (12 * level);
         }
         else if ([[event characters] isEqualToString:@"."]) {
             volume = 50;
             note = b + (12 * level);
         }
         else if ([[event characters] isEqualToString:@"-"]) {
             volume = 50;
             note = a + (12 * level);
         }
         else if ([[event characters] isEqualToString:@" "]) {
             volume = 5;
             note = c + (12 * level);
         }
         else if ([[event characters] isEqualToString:@":"]) {
             volume = 20;
             note = e + (12 * level);
         }
         else {
             note = (12 * level);
         }
         if (level < 3) { level = 3; }
         if (level > 7) { level = 7; }
         if (note > 0) {
             MusicDeviceMIDIEvent(synthUnit,
                              kMidiMessageNoteOn,
                              note, volume, 0);
         }
     }];
    return self;
}
@end
