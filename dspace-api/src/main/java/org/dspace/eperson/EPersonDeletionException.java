/*
 * EPersonDeletionException.java
 *
 * Version: $Revision$
 *
 * Date: $Date$
 *
 * Copyright (c) 2002-2009, The DSpace Foundation.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the DSpace Foundation nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package org.dspace.eperson;

import java.util.List;

/**
 * Exception indicating that an EPerson may not be deleted due to the presence
 * of the EPerson's ID in certain tables
 * 
 * @author Grace Carpenter
 */
public class EPersonDeletionException extends Exception
{
    private List<String> myTableList; //set of tables in which EPerson exists

    /**
     * Create an empty EPersonDeletionException
     */
    public EPersonDeletionException()
    {
        super();
        myTableList = null;
    }

    /**
     * Create an EPersonDeletionException
     * 
     * @param tableList
     *            tables in which the eperson ID exists. An person cannot be
     *            deleted if it exists in these tables.
     *  
     */
    public EPersonDeletionException(List<String> tableList)
    {
        super();
        myTableList = tableList;
    }

    /**
     * Return the list of offending tables.
     * 
     * @return The tables in which the eperson ID exists.
     */
    public List<String> getTables()
    {
        return myTableList;
    }
}
