package com.kc1vmz.osmtilecache.accessor;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/*
    OSM Tile Cache
    Copyright (c) 2026 John Rokicki KC1VMZ

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
    http://www.kc1vmz.com
*/

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.kc1vmz.osmtilecache.config.ProxyConfig;

import jakarta.inject.Inject;
import jakarta.inject.Singleton;

@Singleton
public class TileFileAccessor {
    private static final Logger logger = LogManager.getLogger(TileFileAccessor.class);

    @Inject
    private ProxyConfig proxyConfig;

    public String createTileFile(String filename, byte[] data) {
        String filenameExt = filename+".jpg";
        String fullPath = String.format("%s%s", proxyConfig.getOsmTilesDirectory(), filenameExt);
        try (FileOutputStream fos = new FileOutputStream(fullPath)) {
            fos.write(data);
        } catch (IOException e) {
            logger.error("Exception caught writing file "+fullPath, e);
        }        
        return filenameExt;
    }

    public byte[] getTileFile(String filename) {
        String fullPath = String.format("%s%s", proxyConfig.getOsmTilesDirectory(), filename);
        File file = new File(fullPath);
        byte[] fileBytes = new byte[(int) file.length()];

        try (FileInputStream fis = new FileInputStream(file)) {
            fis.read(fileBytes);
        } catch (IOException e) {
            logger.error("Exception caught reading file "+fullPath, e);
            fileBytes = null;
        }
        return fileBytes;
    }

    public void deleteAll() {
    }
}
